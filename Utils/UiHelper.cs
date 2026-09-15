using System;
using System.Text;
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

        public static string Initial(object value, string fallback = "U")
        {
            string text = value == null || value == DBNull.Value ? null : value.ToString();
            text = text?.Trim();
            return string.IsNullOrEmpty(text) ? fallback : text.Substring(0, 1).ToUpperInvariant();
        }

        public static string CssToken(object value, string fallback = "unknown")
        {
            string text = value == null || value == DBNull.Value ? string.Empty : value.ToString();
            StringBuilder token = new StringBuilder();
            bool separatorPending = false;

            foreach (char character in text.Trim().ToLowerInvariant())
            {
                if (char.IsLetterOrDigit(character))
                {
                    if (separatorPending && token.Length > 0)
                    {
                        token.Append('-');
                    }
                    token.Append(character);
                    separatorPending = false;
                }
                else
                {
                    separatorPending = true;
                }
            }

            return token.Length == 0 ? fallback : token.ToString();
        }
    }
}
