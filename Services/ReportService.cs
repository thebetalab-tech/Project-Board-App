using System;
using System.Data;
using System.IO;
using System.Web;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;

namespace Project_Board.Services
{
    public class ReportService
    {
        // Define theme colors
        private static readonly BaseColor PrimaryColor = new BaseColor(99, 102, 241); // #6366f1
        private static readonly BaseColor TextColor = new BaseColor(51, 51, 51); // #333333
        private static readonly BaseColor SubtextColor = new BaseColor(107, 114, 128); // #6b7280
        private static readonly BaseColor TableHeaderBg = new BaseColor(243, 244, 246); // #f3f4f6

        public static void GeneratePdfReport(string reportTitle, DataTable data, string generatedByName, string generatedByEmail, string filterDescription, HttpResponse response)
        {
            // Set up HTTP response
            response.ContentType = "application/pdf";
            response.AddHeader("content-disposition", $"attachment;filename={reportTitle.Replace(" ", "_")}_{DateTime.Now:yyyyMMdd_HHmm}.pdf");
            response.Cache.SetCacheability(HttpCacheability.NoCache);

            using (Document document = new Document(PageSize.A4, 36, 36, 54, 54))
            {
                PdfWriter writer = PdfWriter.GetInstance(document, response.OutputStream);
                
                // Add page event helper for footer
                writer.PageEvent = new ReportFooter(generatedByName, generatedByEmail);

                document.Open();

                // 1. Header (Letterhead)
                Font headerFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 24, PrimaryColor);
                Paragraph letterhead = new Paragraph("Project Board", headerFont)
                {
                    Alignment = Element.ALIGN_CENTER,
                    SpacingAfter = 10
                };
                document.Add(letterhead);

                // Add a divider line
                LineSeparator line = new LineSeparator(1f, 100f, PrimaryColor, Element.ALIGN_CENTER, -1);
                document.Add(new Chunk(line));
                document.Add(new Paragraph("\n"));

                // 2. Report Title & Meta Info
                Font titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 18, TextColor);
                Paragraph title = new Paragraph(reportTitle, titleFont)
                {
                    Alignment = Element.ALIGN_CENTER,
                    SpacingAfter = 15
                };
                document.Add(title);

                Font metaFont = FontFactory.GetFont(FontFactory.HELVETICA, 10, SubtextColor);
                PdfPTable metaTable = new PdfPTable(2) { WidthPercentage = 100 };
                metaTable.SetWidths(new float[] { 1f, 1f });
                
                PdfPCell dateCell = new PdfPCell(new Phrase($"Generated On: {DateTime.Now:MMM dd, yyyy hh:mm tt}", metaFont)) { Border = Rectangle.NO_BORDER };
                PdfPCell filterCell = new PdfPCell(new Phrase($"Filter: {filterDescription}", metaFont)) { Border = Rectangle.NO_BORDER, HorizontalAlignment = Element.ALIGN_RIGHT };
                
                metaTable.AddCell(dateCell);
                metaTable.AddCell(filterCell);
                document.Add(metaTable);
                document.Add(new Paragraph("\n"));

                // 3. Data Table
                if (data != null && data.Columns.Count > 0)
                {
                    PdfPTable table = new PdfPTable(data.Columns.Count) { WidthPercentage = 100 };
                    table.SpacingBefore = 10f;
                    table.SpacingAfter = 20f;
                    
                    // Table Header
                    Font tableHeaderFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10, TextColor);
                    foreach (DataColumn column in data.Columns)
                    {
                        PdfPCell headerCell = new PdfPCell(new Phrase(column.ColumnName, tableHeaderFont))
                        {
                            BackgroundColor = TableHeaderBg,
                            Padding = 6,
                            HorizontalAlignment = Element.ALIGN_CENTER,
                            VerticalAlignment = Element.ALIGN_MIDDLE
                        };
                        table.AddCell(headerCell);
                    }

                    // Table Rows
                    Font tableCellFont = FontFactory.GetFont(FontFactory.HELVETICA, 9, TextColor);
                    foreach (DataRow row in data.Rows)
                    {
                        foreach (object item in row.ItemArray)
                        {
                            PdfPCell cell = new PdfPCell(new Phrase(item?.ToString() ?? "", tableCellFont))
                            {
                                Padding = 5,
                                VerticalAlignment = Element.ALIGN_MIDDLE
                            };
                            table.AddCell(cell);
                        }
                    }
                    
                    document.Add(table);
                }
                else
                {
                    document.Add(new Paragraph("No data available for this report.", metaFont));
                }

                document.Close();
                response.End();
            }
        }
    }

    public class ReportFooter : PdfPageEventHelper
    {
        private string generatedBy;
        private string email;

        public ReportFooter(string generatedBy, string email)
        {
            this.generatedBy = generatedBy;
            this.email = email;
        }

        public override void OnEndPage(PdfWriter writer, Document document)
        {
            PdfPTable footer = new PdfPTable(3);
            footer.TotalWidth = document.PageSize.Width - document.LeftMargin - document.RightMargin;
            footer.DefaultCell.Border = Rectangle.NO_BORDER;
            
            Font footerFont = FontFactory.GetFont(FontFactory.HELVETICA, 8, new BaseColor(107, 114, 128)); // Subtext color

            // Left: User info
            PdfPCell cellLeft = new PdfPCell(new Phrase($"Generated by: {generatedBy} ({email})", footerFont))
            {
                Border = Rectangle.TOP_BORDER,
                BorderColor = new BaseColor(229, 231, 235), // gray-200
                PaddingTop = 5,
                HorizontalAlignment = Element.ALIGN_LEFT
            };
            
            // Center: Empty or maybe project name again
            PdfPCell cellCenter = new PdfPCell(new Phrase("Project Board", footerFont))
            {
                Border = Rectangle.TOP_BORDER,
                BorderColor = new BaseColor(229, 231, 235),
                PaddingTop = 5,
                HorizontalAlignment = Element.ALIGN_CENTER
            };

            // Right: Page number
            PdfPCell cellRight = new PdfPCell(new Phrase($"Page {writer.PageNumber}", footerFont))
            {
                Border = Rectangle.TOP_BORDER,
                BorderColor = new BaseColor(229, 231, 235),
                PaddingTop = 5,
                HorizontalAlignment = Element.ALIGN_RIGHT
            };

            footer.AddCell(cellLeft);
            footer.AddCell(cellCenter);
            footer.AddCell(cellRight);

            footer.WriteSelectedRows(0, -1, document.LeftMargin, document.BottomMargin - 10, writer.DirectContent);
        }
    }
}
