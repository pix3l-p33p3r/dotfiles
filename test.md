# Complete Font Usage Reference Guide

## Primary Font Mapping Table

| Context | Recommended Font | Rationale | Config Location |
|---------|-----------------|-----------|-----------------|
| **Code Editor (VS Code-cursor/Neovim)** | JetBrainsMono Nerd Font | Ligatures (`!=`, `=>`, `->`) + LSP icons + Git symbols | `~/.config/Code/User/settings.json` or `~/.config/nvim/init.lua` |
| **Terminal (Kitty)** | FiraCode Nerd Font | Operator ligatures + powerline glyphs + shell prompt icons | `~/.config/kitty/kitty.conf` |
| **Obsidian Notes** | Iosevka Nerd Font | Compact width (80% of normal) + high information density + coding support | `~/.obsidian/snippets/fonts.css` |
| **Blog/Website Body** | Noto Sans | Web-safe + 800+ languages + excellent screen rendering | `styles.css` |
| **Blog/Website Code Blocks** | FiraCode Nerd Font | Consistent with terminal + ligatures for code examples | `styles.css` |
| **Technical Documentation** | Noto Serif | High readability for long-form text + professional appearance | LibreOffice/LaTeX default |
| **UI Elements (GNOME/GTK)** | Cantarell | GNOME native font + optimized for small sizes | `~/.config/gtk-3.0/settings.ini` |
| **Emoji & Unicode Symbols** | Noto Nerd Font | Full emoji coverage + dev icons + consistent with Nerd Fonts | Fontconfig default |
| **Arabic Text** | Noto Naskh Arabic UI | Clear at UI sizes + Quranic script + diacritic support | Fontconfig fallback |
| **CJK Languages** | Source Han Sans | Pan-CJK unified design + Adobe quality + excellent hinting | Fontconfig fallback |
| **Engineering Diagrams** | DejaVu Sans | Technical symbols (⊕, ∫, ≈) + circuit notation | Circuit design tools |
| **Mathematical Notation** | Liberation Serif | LaTeX-compatible + equation rendering + proper kerning | LaTeX/Typst documents |
| **Presentations** | Cantarell | High contrast + readable at distance + professional | LibreOffice Impress |
| **Spreadsheets** | Liberation Sans | Number clarity + tabular alignment + Excel compatibility | LibreOffice Calc |


---

## Application-Specific Quick Reference

### **Development Tools**

| Application | Font Setting | Value |
|-------------|--------------|-------|
| **VS Code** | `editor.fontFamily` | `'JetBrainsMono Nerd Font', monospace` |
| **VS Code Terminal** | `terminal.integrated.fontFamily` | `'FiraCode Nerd Font'` |
| **Neovim** | `vim.opt.guifont` | `JetBrainsMono Nerd Font:h12` |
| **Kitty** | `font_family` | `FiraCode Nerd Font` |
| **Tmux** | Uses terminal font | `FiraCode Nerd Font` |
| **Zsh/Bash** | Uses terminal font | `FiraCode Nerd Font` |

### **Productivity Apps**

| Application | Font Setting | Value |
|-------------|--------------|-------|
| **Obsidian (body)** | `--font-text` | `'Noto Sans', sans-serif` |
| **Obsidian (mono)** | `--font-monospace` | `'Iosevka Nerd Font', monospace` |
| **LibreOffice Writer** | Default Paragraph | `Noto Serif, 12pt` |
| **LibreOffice Calc** | Default Cell | `Liberation Sans, 11pt` |
| **LibreOffice Impress** | Title/Body | `Cantarell, 24pt / 16pt` |
| **GIMP** | Interface | `Cantarell, 10pt` |
| **Inkscape** | Interface | `Cantarell, 10pt` |

### **Web Browsers**

| Application | Font Setting | Value |
|-------------|--------------|-------|
| **Firefox (sans)** | `font.name.sans-serif.x-western` | `Noto Sans` |
| **Firefox (serif)** | `font.name.serif.x-western` | `Noto Serif` |
| **Firefox (mono)** | `font.name.monospace.x-western` | `FiraCode Nerd Font` |
| **Chrome/Chromium** | Standard font | `Noto Sans` |
| **Chrome/Chromium** | Fixed-width font | `FiraCode Nerd Font` |

---

## Font Size Recommendations

| Context | Font Size | Line Height | Rationale |
|---------|-----------|-------------|-----------|
| **Code Editor** | 12-14pt | 1.5 | Balance readability and screen real estate |
| **Terminal** | 11-13pt | 1.2 | Denser output for logs/command output |
| **Obsidian Body** | 14-16pt | 1.6 | Comfortable for long reading sessions |
| **Obsidian Code** | 13pt | 1.4 | Slightly smaller than body text |
| **Blog Body** | 16-18px | 1.6 | Optimal for web reading (WCAG compliant) |
| **Blog Code** | 14-16px | 1.5 | Distinct from body, easy to scan |
| **Technical Docs** | 11-12pt | 1.5 | Standard for printed/PDF documents |
| **Presentations** | 24-32pt | 1.3 | Readable from distance |

---


todo list

<!-- hyprlock and hypridle dont work properly if i logout i dont cant login i dont have like the section/space to put the input of my login password in need to be fix -->
