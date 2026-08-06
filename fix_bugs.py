import os

directory = r"d:\E\PROJECTS 2\Project Board\App\Project Board"
files_to_fix = [
    r"Student\Leader\ReviewAppeal.aspx",
    r"Student\Appeal.aspx",
    r"Faculty\ReviewAppeal.aspx",
    r"Admin\ReviewAppeal.aspx"
]

for rel_path in files_to_fix:
    path = os.path.join(directory, rel_path)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Fix the hover button issue
        content = content.replace('var(--c-accent-hover)', 'var(--c-accent-light)')
        
        # Fix the textarea overflowing issue
        if '.form-control {' in content and 'resize: vertical;' not in content:
            content = content.replace('.form-control {', 'textarea.form-control { resize: vertical; max-width: 100%; }\n\n        .form-control {')
            
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Fixed {rel_path}")

# Also fix the admin.css to globally apply textarea resize
admin_css_path = os.path.join(directory, "Admin", "admin.css")
if os.path.exists(admin_css_path):
    with open(admin_css_path, 'r', encoding='utf-8') as f:
        css_content = f.read()
    
    if 'textarea.form-control' not in css_content:
        css_content = css_content.replace('.form-control {', 'textarea.form-control {\n    resize: vertical;\n    max-width: 100%;\n}\n\n.form-control {')
        
        with open(admin_css_path, 'w', encoding='utf-8') as f:
            f.write(css_content)
        print("Fixed admin.css")
