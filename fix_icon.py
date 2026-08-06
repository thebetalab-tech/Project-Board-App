import os
import re

directory = r"d:\E\PROJECTS 2\Project Board\App\Project Board"
files_to_check = []

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(".aspx") or file.endswith(".Master") or file.endswith(".master"):
            files_to_check.append(os.path.join(root, file))

# Pattern to find the exact lingering button
pattern = re.compile(r'\s*<a href=\'(<%= ResolveUrl\("~/User/Profile\.aspx"\) %>|"<%= ResolveUrl\("~/User/Profile\.aspx"\) %>"|~/User/Profile\.aspx)\' class="action-btn" title="Profile">\s*<i class="fa-solid fa-user"></i>\s*</a>', re.DOTALL)
pattern2 = re.compile(r'\s*<a href=\'<%= ResolveUrl\("~/User/Profile\.aspx"\) %>\' class="action-btn" title="Profile">\s*<i class="fa-solid fa-user"></i>\s*</a>', re.DOTALL)


count = 0
for filepath in files_to_check:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content, num_subs = pattern2.subn('', content)
        
    if num_subs > 0 and new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed lingering icon from {filepath}")
        count += 1

print(f"Total files updated: {count}")
