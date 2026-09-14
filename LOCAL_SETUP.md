# Running Project Board locally

Targets .NET Framework 4.7.2 (ASP.NET WebForms). Requires Visual Studio with the
"ASP.NET and web development" workload (ships MSBuild + IIS Express) and a local
SQL Server instance.

## 1. Database

The app ships with a master schema script. Create the database and run it:

```powershell
# adjust -S if your instance name differs (e.g. .\SQLEXPRESS, (localdb)\MSSQLLocalDB)
$S = ".\SQLEXPRESS01"

sqlcmd -S $S -E -C -Q "IF DB_ID('Project_Board') IS NULL CREATE DATABASE Project_Board;"
sqlcmd -S $S -E -C -d Project_Board -b -i "DB\complete_database.sql"
sqlcmd -S $S -E -C -d Project_Board -b -i "DB\deletion_audit_schema.sql"
```

`complete_database.sql` creates all tables and stored procedures and is safe to
re-run; it also migrates older databases in place. `deletion_audit_schema.sql`
adds the `DeletedRecords` audit table, which the master script does not contain.

## 2. Connection string

`Web.config` points at the local instance above. The previously used shared
remote database is kept alongside it, commented out, in case you need it:

```xml
<add name="Project_BoardConnectionString"
     connectionString="Server=.\SQLEXPRESS01;Database=Project_Board;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=True;"
     providerName="System.Data.SqlClient" />
```

Some pages read the name `ProjectBoardDB` first and fall back to
`Project_BoardConnectionString`, so defining only the latter is enough.

## 3. Build and run

Open `Project Board.slnx` in Visual Studio and press F5, or from the command line:

```powershell
$msb = "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe"
& $msb "Project Board.csproj" /t:Build /p:Configuration=Debug

& "C:\Program Files\IIS Express\iisexpress.exe" `
    /config:"$PWD\.vs\Project Board.slnx\config\applicationhost.config" `
    /site:"Project Board"
```

Then browse to <http://localhost:52004/>.

URLs are extensionless — ASP.NET FriendlyUrls redirects `/Login.aspx` to `/Login`.

## Notes

- `Utils/ReportService.cs` must stay out of any folder named `App_Code`. ASP.NET
  compiles `App_Code` at runtime with its own compiler, which both duplicated the
  class already in the project assembly and rejected C# 6+ syntax such as string
  interpolation.
- The `<system.codedom>` block in `Web.config` registers the Roslyn compiler that
  the `Microsoft.CodeDom.Providers.DotNetCompilerPlatform` package provides, so
  any markup compiled at runtime also accepts modern C#.
