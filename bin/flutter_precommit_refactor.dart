import 'dart:io';

import 'package:flutter_precommit_refactor/default_config.dart'; // Import the default YAML configuration
import 'package:process_run/shell.dart';

void main(List<String> arguments) async {
  final shell = Shell();

  if (arguments.isNotEmpty && arguments.first == 'uninstall') {
    await uninstallHooks(shell);
    return;
  }

  print('[INFO] Starting pre-commit setup for this Flutter project with FPR...');

  // Step 1: Check if a custom YAML file is provided
  final userConfigFile = arguments.isNotEmpty ? File(arguments.first) : null;

  if (userConfigFile != null && !userConfigFile.existsSync()) {
    print('[ERROR] Provided YAML file does not exist: ${userConfigFile.path}');
    exit(1);
  }

  // Step 2: Load the YAML configuration (custom or default)
  final yamlContent = userConfigFile != null
      ? userConfigFile.readAsStringSync()
      : defaultYamlConfig; // Updated default config included

  print('[INFO] Using the following configuration:');
  print('---\n$yamlContent\n---');

  // Step 3: Write the configuration to .pre-commit-config.yaml
  final precommitConfig = File('.pre-commit-config.yaml');
  print('[INFO] Creating or updating .pre-commit-config.yaml...');
  precommitConfig.writeAsStringSync(yamlContent);
  print('[SUCCESS] .pre-commit-config.yaml has been created or updated.');

  // Step 4: Set up a virtual environment
  if (!Directory('venv').existsSync()) {
    print('[INFO] Virtual environment not found. Creating a new one...');
    try {
      await shell.run('python3 -m venv venv');
      print('[SUCCESS] Virtual environment created successfully.');
    } catch (e) {
      print('[ERROR] Failed to create virtual environment: $e');
      exit(1);
    }
  } else {
    print('[INFO] Virtual environment already exists. Skipping creation.');
  }

  // Step 5: Install pre-commit using the venv's pip
  print('[INFO] Installing pre-commit in the virtual environment...');
  try {
    final pipResult = await shell.run('./venv/bin/pip install pre-commit');
    print('[SUCCESS] pre-commit installed successfully.');
    print('[DEBUG] pip install output: ${pipResult.outText}');
  } catch (e) {
    print('[ERROR] Failed to install pre-commit in the virtual environment: $e');
    exit(1);
  }

  // Step 6: Install pre-commit hooks using the venv's pre-commit binary
  print('[INFO] Installing pre-commit hooks...');
  try {
    final hookResult = await shell.run('./venv/bin/pre-commit install');
    print('[SUCCESS] Pre-commit hooks installed successfully.');
    print('[DEBUG] pre-commit install output: ${hookResult.outText}');
  } catch (e) {
    print('[ERROR] Failed to install pre-commit hooks: $e');
    exit(1);
  }

  // Step 7: Test pre-commit hooks
  print('[INFO] Testing pre-commit hooks on all files...');
  try {
    final testResult = await shell.run('./venv/bin/pre-commit run --all-files');
    print('[SUCCESS] Pre-commit hooks tested successfully.');
    print('[DEBUG] pre-commit test output: ${testResult.outText}');
  } catch (e) {
    print('[WARNING] Pre-commit hooks encountered issues: $e');
    // Do not exit here; allow the process to complete
  }

  print('[SUCCESS] Setup complete! Pre-commit hooks are now installed and configured.');
}

/// Uninstall all pre-commit hooks
Future<void> uninstallHooks(Shell shell) async {
  print('[INFO] Uninstalling all pre-commit hooks...');
  try {
    final result = await shell.run('./venv/bin/pre-commit uninstall');
    print('[SUCCESS] All pre-commit hooks have been uninstalled.');
    print('[DEBUG] pre-commit uninstall output: ${result.outText}');
  } catch (e) {
    print('[ERROR] Failed to uninstall pre-commit hooks: $e');
    exit(1);
  }

  // Optional: Clean up the virtual environment
  print('[INFO] Removing the virtual environment...');
  try {
    final venvDir = Directory('venv');
    if (venvDir.existsSync()) {
      venvDir.deleteSync(recursive: true);
      print('[SUCCESS] Virtual environment removed.');
    } else {
      print('[INFO] No virtual environment found to remove.');
    }
  } catch (e) {
    print('[WARNING] Failed to remove the virtual environment: $e');
  }

  print('[SUCCESS] Uninstallation process is complete.');
}

/// Check if a command is available on the system
Future<bool> isCommandAvailable(String command) async {
  try {
    final result = await Process.run('which', [command]);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}
