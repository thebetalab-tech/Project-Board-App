import os
import re

directory = r"d:\E\PROJECTS 2\Project Board\App\Project Board"

replacement_str = '<span class="notification-badge"><%= Project_Board.Utils.NotificationHelper.GetUnreadCount(Session["UserId"]) %></span>'

count = 0
for root, _, files in os.walk(directory):
    if "obj" in root or "bin" in root or ".git" in root:
        continue
    for file in files:
        if file.endswith('.aspx') or file.endswith('.Master') or file.endswith('.ascx'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
            except UnicodeDecodeError:
                continue

            # Check if it has a notification badge
            if '<span class="notification-badge">' in content:
                # We need to replace '<span class="notification-badge">0</span>' 
                # or whatever static text is inside the span
                new_content = re.sub(
                    r'<span class="notification-badge">.*?</span>',
                    replacement_str,
                    content
                )
                
                if content != new_content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated badge in {file}")
                    count += 1

print(f"Total files updated: {count}")
