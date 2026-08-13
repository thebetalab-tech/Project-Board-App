using System;
using System.IO;
using System.Text.RegularExpressions;

class Program {
    static void Main() {
        string[] files = Directory.GetFiles(@""d:\E\PROJECTS 2\Project Board\App\Project Board\Admin"", ""*.aspx"");
        foreach(string file in files) {
            if(file.Contains(""Admin_Analysis.aspx"")) continue;
            string content = File.ReadAllText(file);
            if(content.Contains(""Admin_Analysis.aspx"")) continue;
            
            string pattern = @""<a href='<%= ResolveUrl\(""""~/Admin/Admin_Dashboard\.aspx""""\) %>' class=""""nav-link(.*?)"""">\s*<i class=""""fa-solid fa-chart-pie""""></i> Overview\s*</a>"";
            string replacement = ""<a href='<%= ResolveUrl(\""~/Admin/Admin_Dashboard.aspx\"") %>' class=\""nav-link\"">\r\n                    <i class=\""fa-solid fa-chart-pie\""></i> Overview\r\n                </a>\r\n                <a href='<%= ResolveUrl(\""~/Admin/Admin_Analysis.aspx\"") %>' class=\""nav-link\"">\r\n                    <i class=\""fa-solid fa-chart-line\""></i> Analysis & Reports\r\n                </a>"";
            
            string newContent = Regex.Replace(content, pattern, replacement, RegexOptions.Singleline);
            if (newContent != content) {
                File.WriteAllText(file, newContent);
                Console.WriteLine(""Updated "" + Path.GetFileName(file));
            }
        }
    }
}
