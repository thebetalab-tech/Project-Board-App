import os
import re

count = 0
regex = re.compile(r'<div class="logo-icon">.*?</div>\s*', re.DOTALL)

for root, dirs, files in os.walk('.'):
    for f in files:
        if f.endswith(('.aspx', '.Master', '.html')):
            file_path = os.path.join(root, f)
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            
            if '<div class="logo-icon">' in content:
                new_content = regex.sub('', content)
                with open(file_path, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                print(f'Updated {file_path}')
                count += 1

print(f'\nTotal updated: {count}')
