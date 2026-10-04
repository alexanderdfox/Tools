use std::env;
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::PathBuf;

// 1. Define the chemical reagent / overwrite type
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum OverwriteType {
	Null,   // Overwrite with 0x00 bytes
	Random, // Overwrite with pseudo-random bytes
}

// 2. Configuration mimicking reaction cycles and parameters
#[derive(Debug, Clone)]
pub struct ShredConfig {
	pub overwrite_type: OverwriteType,
	pub passes: usize,
}

// 3. Represents an individual file link in our polymer chain
#[derive(Debug, Clone)]
pub struct FileUnit {
	pub path: PathBuf,
	pub config: ShredConfig,
	pub size_bytes: u64,
}

impl FileUnit {
	pub fn new(path: impl Into<PathBuf>, config: ShredConfig) -> io::Result<Self> {
		let path = path.into();
		let metadata = fs::metadata(&path)?;
		Ok(Self {
			path,
			config,
			size_bytes: metadata.len(),
		})
	}
}

// 4. Trait representing the chemical destruction process
pub trait Destructor {
	fn shred(&mut self) -> io::Result<()>;
}

// Simple internal LCG (Linear Congruential Generator) for random pass generation without external crates
struct SimpleRng {
	state: u64,
}

impl SimpleRng {
	fn new(seed: u64) -> Self {
		Self { state: seed }
	}

	fn next_u8(&mut self) -> u8 {
		// Numerical recipes LCG parameters
		self.state = self.state.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
		(self.state >> 56) as u8
	}

	fn fill_buffer(&mut self, buf: &mut [u8]) {
		for b in buf.iter_mut() {
			*b = self.next_u8();
		}
	}
}

// 5. Implement multi-pass destruction (reaction cycles)
impl Destructor for FileUnit {
	fn shred(&mut self) -> io::Result<()> {
		println!("Targeting file link: {:?}", self.path);

		if self.size_bytes > 0 {
			let mut file = OpenOptions::new().write(true).open(&self.path)?;
			let chunk_size = self.size_bytes.min(1024 * 1024) as usize;
			let mut rng = SimpleRng::new(42); // Seed for reproducible pseudo-randomness

			for pass in 1..=self.config.passes {
				print!("  -> Reaction Pass {}/{} ({:?}): ", pass, self.config.passes, self.config.overwrite_type);
				io::stdout().flush()?;

				let mut written = 0;
				while written < self.size_bytes {
					let remaining = (self.size_bytes - written) as usize;
					let current_chunk_size = remaining.min(chunk_size);
					let mut buffer = vec![0u8; current_chunk_size];

					match self.config.overwrite_type {
						OverwriteType::Null => {
							// Leave as zeros (default allocated buffer)
						}
						OverwriteType::Random => {
							rng.fill_buffer(&mut buffer);
						}
					}

					file.write_all(&buffer)?;
					written += current_chunk_size as u64;
				}
				file.sync_all()?;
				println!("Complete.");
			}
		}

		// Unlink/remove the file reference from the filesystem
		fs::remove_file(&self.path)?;
		println!("  -> Polymer chain link dissolved. File permanently purged.\n");
		Ok(())
	}
}

// 6. Polymer Backbone collection
pub struct FileChain {
	pub units: Vec<FileUnit>,
}

impl FileChain {
	pub fn new() -> Self {
		Self { units: Vec::new() }
	}
	pub fn add(&mut self, unit: FileUnit) {
		self.units.push(unit);
	}
}

fn print_help() {
	println!("--- Cis-1,4-Polyisoprene Secure Shredder (rm-style) ---");
	println!("Usage: shredder [OPTIONS] <FILE1> <FILE2> ...");
	println!("Options:");
	println!("  -n, --null             Overwrite with null bytes (0x00) [default]");
	println!("  -r, --random           Overwrite with pseudo-random bytes");
	println!("  -x, --passes <COUNT>   Number of overwrite cycles (default: 3)");
	println!("  -h, --help             Display this help message");
}

fn main() -> io::Result<()> {
	let args: Vec<String> = env::args().collect();
	if args.len() < 2 || args.iter().any(|arg| arg == "-h" || arg == "--help") {
		print_help();
		return Ok(std::io::Result::Ok(()).map(|_| ()).unwrap());
	}

	let mut overwrite_type = OverwriteType::Null;
	let mut passes = 3; // Default multi-pass standard
	let mut file_paths = Vec::new();

	// Simple CLI argument parser loop
	let mut i = 1;
	while i < args.len() {
		match args[i].as_str() {
			"-n" | "--null" => overwrite_type = OverwriteType::Null,
			"-r" | "--random" => overwrite_type = OverwriteType::Random,
			"-x" | "--passes" => {
				if i + 1 < args.len() {
					passes = args[i + 1].parse().unwrap_or(3);
					i += 1;
				}
			}
			path => {
				file_paths.push(path.to_string());
			}
		}
		i += 1;
	}

	if file_paths.is_empty() {
		println!("Error: No target files specified in the polymer chain.");
		print_help();
		return Ok(());
	}

	let config = ShredConfig { overwrite_type, passes };
	let mut chain = FileChain::new();

	for path_str in file_paths {
		match FileUnit::new(&path_str, config.clone()) {
			Ok(unit) => chain.add(unit),
			Err(e) => eprintln!("Warning: Could not access target '{}': {}", path_str, e),
		}
	}

	println!("--- Synthesizing Destruction Chain ({}) ---", chain.units.len());
	println!("Configuration: Passes = {}, Type = {:?}\n", passes, overwrite_type);

	for unit in &mut chain.units {
		unit.shred()?;
	}

	println!("All polymer chains fully dissolved. Operation complete!");
	Ok(())
}