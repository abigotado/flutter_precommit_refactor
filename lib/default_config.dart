const String defaultYamlConfig = '''
repos:
  - repo: local
    hooks:
      - id: dart-format
        name: Format staged Dart files
        entry: |
          bash -c "
          files=\$(git diff --cached --name-only --diff-filter=ACMR | grep '.dart\$');
          if [ -n "\$files" ]; then
            dart format -l 80 \$files || exit 1;
          else
            echo 'No Dart files to format.';
          fi
          "
        language: system
        pass_filenames: false
        always_run: false

      - id: flutter-analyze
        name: Analyze staged Dart files
        entry: |
          bash -c "
          files=\$(git diff --cached --name-only --diff-filter=ACMR | grep '.dart\$');
          if [ -n "\$files" ]; then
            echo "Running flutter analyze on staged files...";
            flutter analyze \\\$files || (echo 'Issues found. Do you want to continue with the commit? (y/n)' && read response && [ \\\$response = 'y' ]);
          else
            echo 'No Dart files to analyze.';
          fi
          "
        language: system
        pass_filenames: false
        always_run: false
''';
