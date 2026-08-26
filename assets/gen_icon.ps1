Add-Type -AssemblyName System.Drawing

$bmp = New-Object System.Drawing.Bitmap(512, 512)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'

# Gradient background: blue to green
$rect = New-Object System.Drawing.Rectangle(0, 0, 512, 512)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(33, 150, 243), [System.Drawing.Color]::FromArgb(76, 175, 80), 45)
$g.FillRectangle($bg, $rect)

# Draw rounded rectangle overlay for modern look
$roundRect = New-Object System.Drawing.Drawing2D.GraphicsPath
$roundRect.AddArc(0, 0, 80, 80, 180, 90)
$roundRect.AddArc(432, 0, 80, 80, 270, 90)
$roundRect.AddArc(432, 432, 80, 80, 0, 90)
$roundRect.AddArc(0, 432, 80, 80, 90, 90)
$roundRect.CloseFigure()
$overlay = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(40, 40, 40, 100), [System.Drawing.Color]::FromArgb(0, 0, 0, 0), 135)
$g.FillPath($overlay, $roundRect)

# Draw dollar sign
$font = New-Object System.Drawing.Font('Arial', 220, [System.Drawing.FontStyle]::Bold)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = 'Center'
$sf.LineAlignment = 'Center'
$g.DrawString('$', $font, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF(0, 0, 512, 512)), $sf)

$bmp.Save('e:\APP\mymastery\assets\app_icon.png', [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host 'Icon generated successfully'
