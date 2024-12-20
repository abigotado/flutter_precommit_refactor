
# **Flutter Precommit Refactor (`fpr`)**

`flutter_precommit_refactor` (command: `fpr`) is a Dart CLI tool designed to simplify the setup of pre-commit hooks for Flutter projects. It automates formatting, static analysis, and interactive bypass during Git commits, ensuring clean and consistent code.

---

## **Features**

- Automatically format staged Dart files using `dart format` (with line length set to 80 characters).
- Run `flutter analyze` on staged files to catch errors or warnings.
- Prompt the user to bypass warnings interactively if necessary.
- Supports default YAML configuration and custom user-provided YAML files.

---

## **Installation**

### **Clone the Repository**

Clone this project or add it to your existing workflow:

```bash
git clone https://github.com/your-repository/flutter_precommit_refactor.git
cd flutter_precommit_refactor
```

### **Install Dependencies**

Ensure you have Dart installed on your system. Then run:

```bash
dart pub get
```

### **Compile the CLI Tool**

Compile the `fpr` command into a standalone executable:

```bash
dart compile exe bin/fpr.dart -o fpr
```

### **Add to PATH**

Move the compiled `fpr` binary to a directory in your `PATH`:

```bash
mv fpr /usr/local/bin/
```

---

## **Usage**

### **Basic Usage**

Run the `fpr` command in the root of your Flutter project to set up pre-commit hooks using the default configuration:

```bash
fpr
```

### **Custom Configuration**

Specify a custom YAML configuration file:

```bash
fpr /path/to/custom_config.yaml
```

The provided YAML file will override the default configuration.

---

## **Default Configuration**

The default configuration is located in `default_precommit_config.yaml`. It includes the following hooks:

### **`dart-format`**

Formats only the staged Dart files with a line length of 80 characters.

```bash
files=$(git diff --cached --name-only --diff-filter=ACMR | grep '.dart$')
if [ -n "$files" ]; then
  dart format -l 80 $files || exit 1
else
  echo "No Dart files to format."
fi
```

### **`flutter-analyze`**

Analyzes only staged Dart files and allows interactive bypass if warnings or errors are found.

```bash
files=$(git diff --cached --name-only --diff-filter=ACMR | grep '.dart$')
if [ -n "$files" ]; then
  flutter analyze $files || (echo "Issues found. Do you want to continue with the commit? (y/n)" && read response && [ "$response" = "y" ])
else
  echo "No Dart files to analyze."
fi
```

---

## **Testing Pre-Commit Hooks**

After installation, test the pre-commit hooks on all files in the repository:

```bash
pre-commit run --all-files
```

---

## **Development**

### **Run the Tool Locally**

You can test the CLI tool without compiling:

```bash
dart run bin/fpr.dart
```

### **Modify the Default Configuration**

Update `default_precommit_config.yaml` to customize the default pre-commit behavior.

### **Dependencies**

The project uses the following Dart packages:

- [`process_run`](https://pub.dev/packages/process_run): To run shell commands.
- [`yaml`](https://pub.dev/packages/yaml): For YAML parsing and writing.

---

## **Contributing**

Contributions are welcome! Feel free to submit issues or pull requests to improve this tool.

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

## **Contact**

For questions or support, please contact:

- **Email**: [nik.koval.89@gmail.com](mailto:nik.koval.89@gmail.com)
- **GitHub**: [Abigotado](https://github.com/abigotado)
