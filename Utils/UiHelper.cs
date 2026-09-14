using System;
using System.Web;

namespace Project_Board.Utils
{
    // Shared rendering for long free-text DB fields (task/project descriptions, report text,
    // appeal reasons, feedback, notification messages, etc.) inside list rows and cards.
    // Encodes the value for safe HTML output, then wraps it in a CSS-clamped container with
    // a "View more" toggle so a large pasted block of text cannot stretch a row/card or
    // misalign sibling columns. Backed by the .text-preview styles in Admin/admin.css and the
    // toggleTextPreview() script in Admin/admin.js, which are loaded on every dashboard page.
    public static class UiHelper
    {
        private const int PreviewThreshold = 150;

        public static string TextPreview(object value)
        {
            return TextPreview(value, "");
        }

        public static string TextPreview(object value, string emptyText)
        {
            string raw = (value == null || value == DBNull.Value) ? null : value.ToString();
            if (string.IsNullOrEmpty(raw))
            {
                return string.IsNullOrEmpty(emptyText) ? "" : HttpUtility.HtmlEncode(emptyText);
            }

            string encoded = HttpUtility.HtmlEncode(raw);

            if (raw.Length <= PreviewThreshold)
            {
                return $"<div class=\"text-preview\"><span class=\"text-preview-content\">{encoded}</span></div>";
            }

            return "<div class=\"text-preview\"><span class=\"text-preview-content\">" + encoded + "</span>"
                 + "<button type=\"button\" class=\"text-preview-toggle\" onclick=\"toggleTextPreview(this)\">View more</button></div>";
        }
    }
}
