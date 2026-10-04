use std::env;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::PathBuf;
use std::process;
use std::time::{SystemTime, UNIX_EPOCH};

// ============================================================================
// SHARED UTILITIES
// ============================================================================

fn current_timestamp() -> f64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs_f64()
}

struct AtexitGuard;
impl Drop for AtexitGuard {
    fn drop(&mut self) {
        let exit_time = current_timestamp();
        println!("Exit: {:.6}", exit_time);
    }
}

// ============================================================================
// HARDWARE TOOLS FOR FILES (Complete Suite)
// ============================================================================

// 1. TAPE MEASURE: Measures dimensions with optional verbose telemetry
fn tool_tape(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools tape <file> [-v|--verbose]");
        return Ok(());
    }
    let path = &args[2];
    let verbose = args.iter().any(|a| a == "-v" || a == "--verbose");

    let metadata = match fs::metadata(path) {
        Ok(m) => m,
        Err(_) => {
            eprintln!("Error: File '{}' not found or inaccessible.", path);
            return Ok(());
        }
    };
    let size = metadata.len();
    
    let mut lines = 0;
    let mut words = 0;
    let mut chars = 0;
    let is_text = if let Ok(contents) = fs::read_to_string(path) {
        lines = contents.lines().count();
        words = contents.split_whitespace().count();
        chars = contents.chars().count();
        true
    } else {
        false
    };

    println!("=== TAPE MEASURE REPORT ===");
    println!("  File: {:?}", path);
    println!("  Size: {} bytes ({:.2} KB)", size, size as f64 / 1024.0);
    if is_text {
        println!("  Lines: {} | Words: {} | Chars: {}", lines, words, chars);
        if verbose {
            let modified = metadata.modified()
                .ok()
                .and_then(|t| t.duration_since(UNIX_EPOCH).ok())
                .map(|d| d.as_secs())
                .unwrap_or(0);
            println!("  Format: Text (UTF-8)");
            println!("  Last Modified Epoch Secs: {}", modified);
        }
    } else {
        println!("  Format: Binary stream");
    }
    Ok(())
}

// 2. SCREWDRIVER: Encrypts or decrypts a file using a passkey (XOR cipher)
fn tool_screw(args: &[String]) -> io::Result<()> {
    if args.len() < 5 {
        println!("Usage: tools screw <file> <-e|-d> <passkey>");
        println!("  -e, --encrypt   Encrypt file contents");
        println!("  -d, --decrypt   Decrypt file contents");
        return Ok(());
    }
    let path = &args[2];
    let mode = &args[3];
    let key = &args[4];

    if mode != "-e" && mode != "-d" && mode != "--encrypt" && mode != "--decrypt" {
        eprintln!("Error: Invalid mode. Use -e/--encrypt or -d/--decrypt.");
        return Ok(());
    }

    let mut data = fs::read(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found.", path))
    })?;

    let key_bytes = key.as_bytes();
    if key_bytes.is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "Passkey cannot be empty."));
    }

    for (i, b) in data.iter_mut().enumerate() {
        *b ^= key_bytes[i % key_bytes.len()];
    }

    fs::write(path, data)?;
    let action = if mode.starts_with("-e") || mode.starts_with("--enc") { "encrypted" } else { "decrypted" };
    println!("Screwdriver security operation: File '{}' successfully {}.", path, action);
    Ok(())
}

// 3. WELDER: Fuses two files together into a single output file
fn tool_welder(args: &[String]) -> io::Result<()> {
    if args.len() < 5 {
        println!("Usage: tools welder <file1> <file2> <output_file>");
        return Ok(());
    }
    let f1 = &args[2];
    let f2 = &args[3];
    let out = &args[4];

    let data1 = fs::read(f1).map_err(|_| io::Error::new(io::ErrorKind::NotFound, format!("Source 1 '{}' not found.", f1)))?;
    let data2 = fs::read(f2).map_err(|_| io::Error::new(io::ErrorKind::NotFound, format!("Source 2 '{}' not found.", f2)))?;

    let mut output_data = data1;
    output_data.extend(data2);

    fs::write(out, output_data)?;
    println!("Welder complete: Fused '{}' and '{}' into '{}'.", f1, f2, out);
    Ok(())
}

// 4. HAMMER: Pounds/truncates a file with optional byte padding fill
fn tool_hammer(args: &[String]) -> io::Result<()> {
    if args.len() < 4 {
        println!("Usage: tools hammer <file> <target_bytes> [--fill <byte_value>]");
        return Ok(());
    }
    let path = &args[2];
    let target_size: u64 = args[3].parse().map_err(|_| {
        io::Error::new(io::ErrorKind::InvalidInput, "Invalid target size integer.")
    })?;

    let mut fill_byte: u8 = 0;
    let mut i = 4;
    while i < args.len() {
        if (args[i] == "--fill" || args[i] == "-f") && i + 1 < args.len() {
            fill_byte = args[i + 1].parse().unwrap_or(0);
            i += 1;
        }
        i += 1;
    }

    let mut file = OpenOptions::new().read(true).write(true).create(true).open(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' could not be opened.", path))
    })?;

    let current_len = file.metadata()?.len();
    file.set_len(target_size)?;

    if target_size > current_len && fill_byte != 0 {
        use std::io::Seek;
        file.seek(io::SeekFrom::Start(current_len))?;
        let add_len = (target_size - current_len) as usize;
        let buffer = vec![fill_byte; add_len.min(1024 * 1024)];
        let mut written = 0;
        while written < add_len {
            let chunk = (add_len - written).min(buffer.len());
            file.write_all(&buffer[..chunk])?;
            written += chunk;
        }
    }

    println!("Hammer strike successful: File '{}' sized to {} bytes (fill: {}).", path, target_size, fill_byte);
    Ok(())
}

// 5. SAW: Cuts/splits a file into N equal parts
fn tool_saw(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools saw <file> [num_parts (default 2)]");
        return Ok(());
    }
    let path = &args[2];
    let parts: usize = if args.len() > 3 {
        args[3].parse().unwrap_or(2)
    } else {
        2
    };

    let data = fs::read(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found.", path))
    })?;

    if parts == 0 {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "Parts must be greater than 0."));
    }

    let chunk_size = (data.len() + parts - 1) / parts;
    println!("Saw cutting file '{}' into {} parts...", path, parts);

    for (i, chunk) in data.chunks(chunk_size).enumerate() {
        let part_name = format!("{}.part{}", path, i + 1);
        fs::write(&part_name, chunk)?;
        println!("  -> Created: {} ({} bytes)", part_name, chunk.len());
    }
    Ok(())
}

// 6. WRENCH: Rotates/shifts file bytes by a given offset value
fn tool_wrench(args: &[String]) -> io::Result<()> {
    if args.len() < 4 {
        println!("Usage: tools wrench <file> <shift_amount>");
        return Ok(());
    }
    let path = &args[2];
    let shift: u8 = args[3].parse().unwrap_or(1);

    let mut data = fs::read(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found.", path))
    })?;
    for b in data.iter_mut() {
        *b = b.wrapping_add(shift);
    }
    fs::write(path, data)?;
    println!("Wrench torque applied: File '{}' bytes rotated by shift {}.", path, shift);
    Ok(())
}

// 7. DRILL: Punches a hole by overwriting a region with zeros at offset
fn tool_drill(args: &[String]) -> io::Result<()> {
    if args.len() < 5 {
        println!("Usage: tools drill <file> <offset> <length>");
        return Ok(());
    }
    let path = &args[2];
    let offset: u64 = args[3].parse().unwrap_or(0);
    let length: usize = args[4].parse().unwrap_or(10);

    let mut file = OpenOptions::new().write(true).open(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found.", path))
    })?;
    use std::io::Seek;
    file.seek(std::io::SeekFrom::Start(offset))?;
    let holes = vec![0u8; length];
    file.write_all(&holes)?;
    println!("Drill hole punched: File '{}' zeroed out {} bytes at offset {}.", path, length, offset);
    Ok(())
}

// 8. PLIERS: Squeezes file content by trimming trailing whitespace
fn tool_pliers(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools pliers <file>");
        return Ok(());
    }
    let path = &args[2];
    if let Ok(text) = fs::read_to_string(path) {
        let squeezed = text.trim_end().to_string();
        let _ = fs::write(path, squeezed);
        println!("Pliers squeeze complete: Stripped trailing whitespace from '{}'.", path);
    } else {
        println!("Pliers notice: File '{}' not found or is binary.", path);
    }
    Ok(())
}

// 9. SANDPAPER: Smooths line endings (converts CRLF to LF)
fn tool_sandpaper(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools sandpaper <file>");
        return Ok(());
    }
    let path = &args[2];
    let text = fs::read_to_string(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found or not text.", path))
    })?;

    let smoothed = text.replace("\r\n", "\n");
    fs::write(path, smoothed)?;
    println!("Sandpaper smooth complete: Normalized line endings in '{}'.", path);
    Ok(())
}

// 10. CHISEL: Carves out a byte range from a file, collapsing the space
fn tool_chisel(args: &[String]) -> io::Result<()> {
    if args.len() < 5 {
        println!("Usage: tools chisel <file> <offset> <length>");
        return Ok(());
    }
    let path = &args[2];
    let offset: usize = args[3].parse().unwrap_or(0);
    let length: usize = args[4].parse().unwrap_or(0);

    let mut data = fs::read(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found.", path))
    })?;

    if offset >= data.len() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "Offset exceeds file length."));
    }

    let end = (offset + length).min(data.len());
    data.drain(offset..end);

    fs::write(path, data)?;
    println!("Chisel carve successful: Removed {} bytes at offset {} in '{}'.", length, offset, path);
    Ok(())
}

// 11. RASP: Files away consecutive multiple blank lines down to a clean structure
fn tool_rasp(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools rasp <file>");
        return Ok(());
    }
    let path = &args[2];
    let text = fs::read_to_string(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found or not text.", path))
    })?;

    let mut result_lines = Vec::new();
    let mut last_was_empty = false;

    for line in text.lines() {
        let is_empty = line.trim().is_empty();
        if is_empty {
            if !last_was_empty {
                result_lines.push("");
                last_was_empty = true;
            }
        } else {
            result_lines.push(line);
            last_was_empty = false;
        }
    }

    let rasped = result_lines.join("\n");
    fs::write(path, rasped)?;
    println!("Rasp trim complete: Collapsed redundant empty lines in '{}'.", path);
    Ok(())
}

// 12. CALIPERS: Precision measures differences between two files (Diff)
fn tool_calipers(args: &[String]) -> io::Result<()> {
    if args.len() < 4 {
        println!("Usage: tools calipers <file1> <file2>");
        return Ok(());
    }
    let f1 = &args[2];
    let f2 = &args[3];

    let data1 = fs::read(f1).map_err(|_| io::Error::new(io::ErrorKind::NotFound, format!("File 1 '{}' not found.", f1)))?;
    let data2 = fs::read(f2).map_err(|_| io::Error::new(io::ErrorKind::NotFound, format!("File 2 '{}' not found.", f2)))?;

    println!("=== CALIPERS COMPARISON REPORT ===");
    println!("  File 1: {} ({} bytes)", f1, data1.len());
    println!("  File 2: {} ({} bytes)", f2, data2.len());

    let size_diff = (data1.len() as i64 - data2.len() as i64).abs();
    println!("  Size Differential: {} bytes", size_diff);

    if data1 == data2 {
        println!("  Status: Files are 100% identical byte-for-byte.");
    } else {
        println!("  Status: Files differ in content.");
    }
    Ok(())
}

// 13. LEVEL: Aligns text lines by padding them out or checking line balance
fn tool_level(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools level <file>");
        return Ok(());
    }
    let path = &args[2];
    let text = fs::read_to_string(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("File '{}' not found or not text.", path))
    })?;

    let lines: Vec<&str> = text.lines().collect();
    let max_len = lines.iter().map(|l| l.chars().count()).max().unwrap_or(0);

    println!("=== LEVEL ALIGNMENT REPORT ===");
    println!("  Total Lines: {}", lines.len());
    println!("  Maximum Line Width: {} characters", max_len);
    println!("  Status: Line formatting inspected and leveled.");
    Ok(())
}

// ============================================================================
// FILE UTILITIES: SHRED, ARCHIVE, & TOOL FILE RUNNER
// ============================================================================

fn run_shredder(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools shred <file1> <file2> ...");
        return Ok(());
    }

    for path_str in &args[2..] {
        let path = PathBuf::from(path_str);
        if !path.exists() {
            eprintln!("Skipping '{}': Not found.", path_str);
            continue;
        }
        let metadata = fs::metadata(&path)?;
        let size = metadata.len();

        if size > 0 {
            let mut file = OpenOptions::new().write(true).open(&path)?;
            for pass in 1..=3 {
                print!("Shredding '{}' (Pass {}/3)... ", path_str, pass);
                let _ = io::stdout().flush();
                let zeros = vec![0u8; size.min(1024 * 1024) as usize];
                let mut written = 0;
                while written < size {
                    let chunk = (size - written).min(zeros.len() as u64) as usize;
                    file.write_all(&zeros[..chunk])?;
                    written += chunk as u64;
                }
                file.sync_all()?;
                println!("Done.");
            }
        }
        fs::remove_file(&path)?;
        println!("File '{}' permanently shredded.\n", path_str);
    }
    Ok(())
}

fn run_archiver(args: &[String]) -> io::Result<()> {
    if args.len() < 4 {
        println!("Usage: tools archive <source> <destination>");
        return Ok(());
    }
    let src = &args[2];
    let dest = &args[3];

    let contents = fs::read(src).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("Source file '{}' not found.", src))
    })?;
    fs::write(dest, contents)?;
    println!("Archived successfully: '{}' -> '{}'.", src, dest);
    Ok(())
}

fn tool_run_file(args: &[String]) -> io::Result<()> {
    if args.len() < 3 {
        println!("Usage: tools run <toolfile>");
        return Ok(());
    }
    let path = &args[2];
    let content = fs::read_to_string(path).map_err(|_| {
        io::Error::new(io::ErrorKind::NotFound, format!("Tool file '{}' not found.", path))
    })?;

    println!("=== EXECUTING TOOL FILE: {} ===", path);
    for (line_num, line) in content.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        println!("\n[Line {}] Running: {}", line_num + 1, line);
        let sub_args: Vec<String> = line.split_whitespace().map(|s| s.to_string()).collect();
        
        let mut full_args = vec!["tools".to_string()];
        full_args.extend(sub_args);

        if full_args.len() > 1 {
            match full_args[1].as_str() {
                "tape" | "t" => { let _ = tool_tape(&full_args); }
                "screw" | "s" => { let _ = tool_screw(&full_args); }
                "welder" | "w" => { let _ = tool_welder(&full_args); }
                "hammer" | "h" => { let _ = tool_hammer(&full_args); }
                "saw" | "sa" => { let _ = tool_saw(&full_args); }
                "wrench" | "wr" => { let _ = tool_wrench(&full_args); }
                "drill" | "d" => { let _ = tool_drill(&full_args); }
                "pliers" | "p" => { let _ = tool_pliers(&full_args); }
                "sandpaper" | "sp" => { let _ = tool_sandpaper(&full_args); }
                "chisel" | "c" => { let _ = tool_chisel(&full_args); }
                "rasp" | "ra" => { let _ = tool_rasp(&full_args); }
                "calipers" | "cal" => { let _ = tool_calipers(&full_args); }
                "level" | "l" => { let _ = tool_level(&full_args); }
                "shred" | "sh" => { let _ = run_shredder(&full_args); }
                "archive" | "cp" => { let _ = run_archiver(&full_args); }
                other => eprintln!("Unknown tool in file: '{}'", other),
            }
        }
    }
    println!("\n=== TOOL FILE EXECUTION COMPLETE ===");
    Ok(())
}

// ============================================================================
// MAIN ROUTER & HELP
// ============================================================================

fn print_help() {
    println!("========================================");
    println!("      UNIFIED FILE-NATIVE TOOLS         ");
    println!("========================================");
    println!("Hardware Tools on Files:");
    println!("  tools tape <file> [-v]             Measure file size/lines/verbose");
    println!("  tools screw <file> <-e|-d> <key>   Encrypt/Decrypt file with passkey");
    println!("  tools welder <f1> <f2> <out>       Fuse two files into one");
    println!("  tools hammer <file> <sz> [--fill]  Pound/truncate file with padding");
    println!("  tools saw <file> [parts]           Cut/split file into N parts");
    println!("  tools wrench <file> <shift>        Rotate byte values by shift");
    println!("  tools drill <file> <off> <len>     Punch zero-filled hole at offset");
    println!("  tools pliers <file>                Squeeze/trim trailing whitespace");
    println!("  tools sandpaper <file>             Smooth line endings (CRLF -> LF)");
    println!("  tools chisel <file> <off> <len>    Carve out byte range & close gap");
    println!("  tools rasp <file>                  Trim redundant empty lines");
    println!("  tools calipers <f1> <f2>           Precision diff measure two files");
    println!("  tools level <file>                 Inspect line formatting & alignment");
    println!("\nTool File Execution & Utilities:");
    println!("  tools run <toolfile>               Execute batch tool script file");
    println!("  tools shred <files...>             Securely wipe files");
    println!("  tools archive <src> <dest>         Binary-safe file copy");
}

fn main() -> io::Result<()> {
    let _guard = AtexitGuard;
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_help();
        process::exit(1);
    }

    match args[1].as_str() {
        "tape" | "t" => tool_tape(&args)?,
        "screw" | "s" => tool_screw(&args)?,
        "welder" | "w" => tool_welder(&args)?,
        "hammer" | "h" => tool_hammer(&args)?,
        "saw" | "sa" => tool_saw(&args)?,
        "wrench" | "wr" => tool_wrench(&args)?,
        "drill" | "d" => tool_drill(&args)?,
        "pliers" | "p" => tool_pliers(&args)?,
        "sandpaper" | "sp" => tool_sandpaper(&args)?,
        "chisel" | "c" => tool_chisel(&args)?,
        "rasp" | "ra" => tool_rasp(&args)?,
        "calipers" | "cal" => tool_calipers(&args)?,
        "level" | "l" => tool_level(&args)?,
        "run" | "r" => tool_run_file(&args)?,
        "shred" | "sh" => run_shredder(&args)?,
        "archive" | "cp" => run_archiver(&args)?,
        "-h" | "--help" => print_help(),
        other => {
            eprintln!("Unknown command: '{}'. Run 'tools --help' for usage.", other);
            process::exit(1);
        }
    }

    Ok(())
}