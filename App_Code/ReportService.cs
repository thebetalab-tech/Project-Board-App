using System;
using System.Data;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using System.Web;

namespace Project_Board.Utils
{
    public static class ReportService
    {
        // Define our theme colors
        private static readonly BaseColor ThemePrimary = new BaseColor(99, 102, 241); // #6366f1
        private static readonly BaseColor ThemeSecondary = new BaseColor(79, 70, 229); // #4f46e5
        private static readonly BaseColor TextColor = new BaseColor(30, 41, 59); // #1e293b
        private static readonly BaseColor TextMuted = new BaseColor(100, 116, 139); // #64748b
        private static readonly BaseColor BorderColor = new BaseColor(226, 232, 240); // #e2e8f0
        private static readonly BaseColor HeaderBg = new BaseColor(248, 250, 252); // #f8fafc

        public static byte[] GeneratePdfReport(string reportTitle, DataTable data, string generatedByName, string generatedByEmail, List<string> selectedColumns = null)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                // Create document with standard margins
                Document doc = new Document(PageSize.A4, 36, 36, 120, 50);
                PdfWriter writer = PdfWriter.GetInstance(doc, ms);

                // Add Page Event Helper for Footer (and background)
                writer.PageEvent = new ReportPageEventHelper(generatedByName, generatedByEmail);

                doc.Open();

                // Build Letterhead Header
                PdfPTable headerTable = new PdfPTable(2);
                headerTable.WidthPercentage = 100;
                headerTable.SetWidths(new float[] { 2f, 1f });
                headerTable.SpacingAfter = 30f;

                // Left side: Project Board & Title
                PdfPCell leftCell = new PdfPCell();
                leftCell.Border = Rectangle.NO_BORDER;
                leftCell.VerticalAlignment = Element.ALIGN_MIDDLE;
                
                Font titleFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 24, ThemePrimary);
                leftCell.AddElement(new Phrase("PROJECT BOARD", titleFont));
                
                Font subtitleFont = FontFactory.GetFont(FontFactory.HELVETICA, 14, TextMuted);
                Paragraph subtitle = new Paragraph(reportTitle, subtitleFont);
                subtitle.SpacingBefore = 5f;
                leftCell.AddElement(subtitle);
                
                headerTable.AddCell(leftCell);

                // Right side: Date Info
                PdfPCell rightCell = new PdfPCell();
                rightCell.Border = Rectangle.NO_BORDER;
                rightCell.HorizontalAlignment = Element.ALIGN_RIGHT;
                rightCell.VerticalAlignment = Element.ALIGN_MIDDLE;
                
                Font dateFont = FontFactory.GetFont(FontFactory.HELVETICA, 10, TextMuted);
                Paragraph datePara = new Paragraph("Date Generated:", dateFont);
                datePara.Alignment = Element.ALIGN_RIGHT;
                rightCell.AddElement(datePara);
                
                Font dateValFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10, TextColor);
                Paragraph dateValPara = new Paragraph(DateTime.Now.ToString("dd MMM yyyy, HH:mm"), dateValFont);
                dateValPara.Alignment = Element.ALIGN_RIGHT;
                rightCell.AddElement(dateValPara);

                headerTable.AddCell(rightCell);
                doc.Add(headerTable);

                // Add colored line separator
                LineSeparator line = new LineSeparator(2f, 100f, ThemePrimary, Element.ALIGN_CENTER, -10f);
                doc.Add(new Chunk(line));
                doc.Add(new Paragraph(" "));
                doc.Add(new Paragraph(" "));

                // Filter columns if needed
                List<DataColumn> colsToExport = new List<DataColumn>();
                if (selectedColumns != null && selectedColumns.Count > 0)
                {
                    foreach (DataColumn col in data.Columns)
                    {
                        if (selectedColumns.Contains(col.ColumnName))
                        {
                            colsToExport.Add(col);
                        }
                    }
                }
                else
                {
                    foreach (DataColumn col in data.Columns)
                    {
                        colsToExport.Add(col);
                    }
                }

                if (colsToExport.Count > 0 && data.Rows.Count > 0)
                {
                    PdfPTable dataTable = new PdfPTable(colsToExport.Count);
                    dataTable.WidthPercentage = 100;

                    // Table Header
                    Font thFont = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 10, TextColor);
                    foreach (DataColumn col in colsToExport)
                    {
                        PdfPCell cell = new PdfPCell(new Phrase(col.ColumnName, thFont));
                        cell.BackgroundColor = HeaderBg;
                        cell.BorderColor = BorderColor;
                        cell.Padding = 8f;
                        cell.HorizontalAlignment = Element.ALIGN_LEFT;
                        dataTable.AddCell(cell);
                    }

                    // Table Body
                    Font tdFont = FontFactory.GetFont(FontFactory.HELVETICA, 9, TextColor);
                    bool isAlternate = false;
                    
                    foreach (DataRow row in data.Rows)
                    {
                        foreach (DataColumn col in colsToExport)
                        {
                            PdfPCell cell = new PdfPCell(new Phrase(row[col].ToString(), tdFont));
                            cell.BorderColor = BorderColor;
                            cell.Padding = 6f;
                            if (isAlternate) cell.BackgroundColor = new BaseColor(250, 250, 250);
                            dataTable.AddCell(cell);
                        }
                        isAlternate = !isAlternate;
                    }

                    doc.Add(dataTable);
                }
                else
                {
                    Font emptyFont = FontFactory.GetFont(FontFactory.HELVETICA_OBLIQUE, 12, TextMuted);
                    Paragraph emptyMsg = new Paragraph("No data available for the selected filters.", emptyFont);
                    emptyMsg.Alignment = Element.ALIGN_CENTER;
                    emptyMsg.SpacingBefore = 20f;
                    doc.Add(emptyMsg);
                }

                doc.Close();
                return ms.ToArray();
            }
        }
    }

    public class ReportPageEventHelper : PdfPageEventHelper
    {
        private readonly string _userName;
        private readonly string _userEmail;
        
        private static readonly BaseColor ThemePrimary = new BaseColor(99, 102, 241); // #6366f1
        private static readonly BaseColor FooterBorderColor = new BaseColor(226, 232, 240); // #e2e8f0
        private static readonly BaseColor TextMuted = new BaseColor(100, 116, 139); // #64748b

        public ReportPageEventHelper(string userName, string userEmail)
        {
            _userName = userName ?? "System User";
            _userEmail = userEmail ?? "";
        }

        public override void OnEndPage(PdfWriter writer, Document document)
        {
            PdfContentByte cb = writer.DirectContent;

            // Draw Top Border line for header aesthetics (optional)
            cb.SetColorStroke(ThemePrimary);
            cb.SetLineWidth(4f);
            cb.MoveTo(document.LeftMargin, document.PageSize.Height - 15);
            cb.LineTo(document.PageSize.Width - document.RightMargin, document.PageSize.Height - 15);
            cb.Stroke();

            // Draw Top thin border
            cb.SetColorStroke(new BaseColor(199, 210, 254)); // Indigo-200
            cb.SetLineWidth(1f);
            cb.MoveTo(document.LeftMargin, document.PageSize.Height - 19);
            cb.LineTo(document.PageSize.Width - document.RightMargin, document.PageSize.Height - 19);
            cb.Stroke();

            // FOOTER
            // Draw a separator line for the footer
            cb.SetColorStroke(FooterBorderColor);
            cb.SetLineWidth(1f);
            cb.MoveTo(document.LeftMargin, document.BottomMargin + 10);
            cb.LineTo(document.PageSize.Width - document.RightMargin, document.BottomMargin + 10);
            cb.Stroke();

            // Setup Fonts
            BaseFont bf = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
            
            // Text: Generated By
            cb.BeginText();
            cb.SetFontAndSize(bf, 8);
            cb.SetColorFill(TextMuted);
            cb.ShowTextAligned(PdfContentByte.ALIGN_LEFT, 
                $"Generated by: {_userName} {(!string.IsNullOrEmpty(_userEmail) ? $"({_userEmail})" : "")}", 
                document.LeftMargin, document.BottomMargin - 5, 0);

            // Text: Page Number
            cb.ShowTextAligned(PdfContentByte.ALIGN_RIGHT, 
                $"Page {writer.PageNumber}", 
                document.PageSize.Width - document.RightMargin, document.BottomMargin - 5, 0);
            cb.EndText();
        }
    }
}
