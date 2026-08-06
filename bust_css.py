import os
import re

directory = r"d:\E\PROJECTS 2\Project Board\App\Project Board"

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(".aspx") or file.endswith(".Master"):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = re.sub(r'admin\.css\?v=([a-zA-Z0-9_]+)', 'admin.css?v=latest_v3', content)
            
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
print("CSS Cache Buster Updated!")
