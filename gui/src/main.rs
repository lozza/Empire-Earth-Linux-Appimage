slint::include_modules!();
use std::{fs::{self, File}, io::{BufRead, BufReader, Write}, path::{Path, PathBuf}, process::{Command, Stdio}, time::{SystemTime, UNIX_EPOCH}};

fn main() -> Result<(), slint::PlatformError> {
    let ui = MainWindow::new()?;
    if let Some(home) = std::env::var_os("HOME") {
        let downloads = PathBuf::from(home).join("Downloads");
        ui.set_output_path(downloads.join("Empire Earth AppImage").to_string_lossy().into_owned().into());
        if let Ok(entries) = fs::read_dir(&downloads) {
            for entry in entries.flatten() {
                let name = entry.file_name().to_string_lossy().to_ascii_lowercase();
                if name.starts_with("setup_empire_earth_gold_") && name.ends_with(".exe") {
                    ui.set_installer_path(entry.path().to_string_lossy().into_owned().into());
                    break;
                }
            }
        }
    }
    if let Some(home) = std::env::var_os("HOME") {
        let cab = PathBuf::from(home).join(".local/share/Steam/steamapps/common/Age Of Empires 3/directx/dxnt.cab");
        if cab.is_file() { ui.set_directmusic_path(cab.to_string_lossy().into_owned().into()); }
    }
    let weak = ui.as_weak();
    ui.on_browse_installer(move || browse(weak.clone(), 0));
    let weak = ui.as_weak();
    ui.on_browse_directmusic(move || browse(weak.clone(), 1));
    let weak = ui.as_weak();
    ui.on_browse_output(move || browse(weak.clone(), 2));
    let weak = ui.as_weak();
    ui.on_request_build(move |installer, directmusic, output, profile_index| {
        let Some(window) = weak.upgrade() else { return };
        if window.get_building() || window.get_choosing() || window.get_backing_up() { return; }
        let installer = PathBuf::from(installer.trim().to_string());
        let directmusic = PathBuf::from(directmusic.trim().to_string());
        let output = PathBuf::from(output.trim().to_string());
        if !installer.is_file() || !directmusic.exists() || !output.is_absolute() {
            window.set_build_failed(true);
            window.set_status_text("Choose the GOG installer, a DirectMusic CAB or DLL folder, and a full output-folder path.".into());
            return;
        }
        let profile = match profile_index { 0 => "720p", 1 => "deck", 2 => "1080p", _ => "720p" };
        window.set_building(true);
        window.set_build_failed(false);
        window.set_build_finished(false);
        window.set_progress_value(0.0);
        window.set_status_text("Starting build…".into());
        window.set_diagnostic_text("Starting build…".into());
        let thread_weak = weak.clone();
        std::thread::spawn(move || {
            let appdir = std::env::var_os("EE_BUILDER_DIR").map(PathBuf::from)
                .unwrap_or_else(|| std::env::current_exe().unwrap().parent().unwrap().to_path_buf());
            let _ = fs::create_dir_all(&output);
            let mut log = File::create(output.join("empire-earth-builder.log")).ok();
            let result = Command::new("bash")
                .arg("-c").arg("exec \"$@\" 2>&1").arg("builder")
                .arg(appdir.join("build-game.sh"))
                .arg(&installer).arg(&directmusic).arg(&output).arg(profile)
                .stdout(Stdio::piped()).stderr(Stdio::null()).spawn();
            let mut lines = String::new();
            let status = match result {
                Ok(mut child) => {
                    if let Some(stdout) = child.stdout.take() {
                        for line in BufReader::new(stdout).lines().map_while(Result::ok) {
                            if let Some(file) = &mut log { let _ = writeln!(file, "{line}"); }
                            lines.push_str(&line); lines.push('\n');
                            show_line(&thread_weak, &line, &lines);
                        }
                    }
                    let result = child.wait_with_output();
                    match result {
                        Ok(output) => {
                            let errors = String::from_utf8_lossy(&output.stderr);
                            if let Some(file) = &mut log { let _ = write!(file, "{errors}"); }
                            if !errors.is_empty() { lines.push_str(&errors); show_line(&thread_weak, errors.trim(), &lines); }
                            output.status.success()
                        }
                        Err(error) => { lines.push_str(&error.to_string()); false }
                    }
                }
                Err(error) => { lines.push_str(&format!("Cannot start builder: {error}")); false }
            };
            let message = if status { format!("Game AppImage ready in {}", output.display()) }
                else { format!("Build failed. See empire-earth-builder.log in {}", output.display()) };
            let _ = slint::invoke_from_event_loop(move || {
                if let Some(window) = thread_weak.upgrade() {
                    window.set_building(false);
                    window.set_build_finished(status);
                    window.set_build_failed(!status);
                    window.set_progress_value(if status { 1.0 } else { 0.0 });
                    window.set_status_text(message.into());
                    window.set_diagnostic_text(lines.into());
                }
            });
        });
    });
    let weak = ui.as_weak();
    ui.on_request_backup(move |output| {
        let Some(window) = weak.upgrade() else { return };
        if window.get_building() || window.get_choosing() || window.get_backing_up() { return; }
        let output = PathBuf::from(output.trim().to_string());
        if !output.is_absolute() {
            window.set_status_text("Choose a full output-folder path for the backup.".into());
            return;
        }
        let Some(home) = std::env::var_os("HOME") else {
            window.set_status_text("Cannot locate your home folder for the backup.".into());
            return;
        };
        let data_home = std::env::var_os("XDG_DATA_HOME").map(PathBuf::from)
            .unwrap_or_else(|| PathBuf::from(home).join(".local/share"));
        let source = data_home.join("empire-earth-gog-private-test");
        if !source.is_dir() {
            window.set_status_text("No Empire Earth saves or settings exist yet.".into());
            return;
        }
        window.set_backing_up(true);
        window.set_status_text("Backing up game data, saves, settings, and prefix…".into());
        let thread_weak = weak.clone();
        std::thread::spawn(move || {
            let stamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs();
            let target = output.join(format!("Empire-Earth-data-backup-{stamp}.tar.gz"));
            let partial = target.with_extension("tar.gz.partial");
            let result = fs::create_dir_all(&output).and_then(|_| {
                let result = Command::new("tar").args(["-czf"]).arg(&partial)
                    .arg("-C").arg(&data_home).arg("empire-earth-gog-private-test").output()?;
                if result.status.success() { fs::rename(&partial, &target) }
                else { Err(std::io::Error::other(String::from_utf8_lossy(&result.stderr).to_string())) }
            });
            if result.is_err() { let _ = fs::remove_file(&partial); }
            let message = match result {
                Ok(()) => format!("Backup ready: {}", target.display()),
                Err(error) => format!("Backup failed: {error}"),
            };
            let _ = slint::invoke_from_event_loop(move || {
                if let Some(window) = thread_weak.upgrade() {
                    window.set_backing_up(false);
                    window.set_status_text(message.into());
                }
            });
        });
    });
    ui.run()
}

fn show_line(weak: &slint::Weak<MainWindow>, line: &str, lines: &str) {
    let weak = weak.clone();
    let line = line.to_string();
    let lines = lines.to_string();
    let _ = slint::invoke_from_event_loop(move || {
        if let Some(window) = weak.upgrade() {
            window.set_status_text(line.clone().into());
            let progress = if line.starts_with("Downloading verified soda") { 0.08 }
                else if line.starts_with("Downloading verified dxvk") { 0.18 }
                else if line.starts_with("Downloading verified appimagetool") { 0.28 }
                else if line.starts_with("Installing pinned") { 0.38 }
                else if line.starts_with("Extracting your GOG") { 0.48 }
                else if line.starts_with("Adding Wine") { 0.65 }
                else if line.starts_with("Packaging the private") { 0.82 }
                else if line.starts_with("BUILD COMPLETE") { 1.0 }
                else { window.get_progress_value() };
            window.set_progress_value(progress);
            window.set_diagnostic_text(lines.into());
        }
    });
}

fn browse(weak: slint::Weak<MainWindow>, kind: u8) {
    let Some(window) = weak.upgrade() else { return };
    if window.get_building() || window.get_choosing() || window.get_backing_up() { return; }
    window.set_choosing(true);
    std::thread::spawn(move || {
        let path = pick_path(kind);
        let _ = slint::invoke_from_event_loop(move || {
            if let Some(window) = weak.upgrade() {
                window.set_choosing(false);
                match path {
                    Ok(Some(path)) => {
                        match kind {
                            0 => window.set_installer_path(path.into()),
                            1 => window.set_directmusic_path(path.into()),
                            _ => window.set_output_path(path.into()),
                        }
                        window.set_status_text("Selection ready.".into());
                    }
                    Ok(None) => window.set_status_text("Selection cancelled.".into()),
                    Err(error) => window.set_status_text(format!("{error} Paste the full path into the field.").into()),
                }
            }
        });
    });
}

fn pick_path(kind: u8) -> Result<Option<String>, String> {
    let host_spawn = Path::new("/run/host/usr/bin/flatpak-spawn");
    let has_kdialog = host_spawn.is_file() || command_on_path("kdialog");
    let mut command = if host_spawn.is_file() {
        let mut cmd = Command::new(host_spawn); cmd.args(["--host", "kdialog"]); cmd
    } else if has_kdialog { Command::new("kdialog") }
    else if command_on_path("zenity") { Command::new("zenity") }
    else { return Err("No file chooser was found.".into()); };
    let start = std::env::var("HOME").unwrap_or_else(|_| "/".into());
    if has_kdialog {
        match kind {
            0 => { command.args(["--getopenfilename", &start, "*.exe|GOG installers"]); }
            1 => { command.args(["--getopenfilename", &start, "*.cab|DirectMusic CAB"]); }
            _ => { command.args(["--getexistingdirectory", &start]); }
        }
    } else {
        match kind {
            0 => { command.args(["--file-selection", "--title=Choose GOG installer", "--filename", &start]); }
            1 => { command.args(["--file-selection", "--title=Choose DirectMusic CAB", "--filename", &start]); }
            _ => { command.args(["--file-selection", "--directory", "--title=Choose output folder", "--filename", &start]); }
        }
    }
    let result = command.output().map_err(|error| error.to_string())?;
    if result.status.code() == Some(1) { return Ok(None); }
    if !result.status.success() { return Err(String::from_utf8_lossy(&result.stderr).trim().to_string()); }
    let path = String::from_utf8(result.stdout).map_err(|_| "Selected path is not UTF-8".to_string())?;
    let path = path.trim();
    Ok(if path.is_empty() { None } else { Some(path.to_string()) })
}
fn command_on_path(name: &str) -> bool {
    std::env::var_os("PATH").is_some_and(|paths| std::env::split_paths(&paths).any(|dir| dir.join(name).is_file()))
}
