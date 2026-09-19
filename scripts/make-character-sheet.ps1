# Builds two review images from the frames that godot/tests/capture_character.gd renders.
#
#   evidence/screens/character/SHEET-beacon-states.png    six states, 5x nearest-neighbour
#   evidence/screens/character/SHEET-collider-check.png   the 18x28 collider drawn over the art
#
# Run capture_character.gd first:
#   <godot> --path godot --script res://tests/capture_character.gd
# then:
#   powershell -ExecutionPolicy Bypass -File scripts/make-character-sheet.ps1
#
# Geometry notes, so the overlay can be checked rather than trusted:
#   - session.gd sets camera.x = clampf(player.x + 100, 320, width - 320). Away from the
#     clamp the player therefore sits at a fixed 220 in the 640-wide viewport, which is
#     x = 440 in the 1280x720 render.
#   - camera.y is a constant 180 in a 360-tall viewport, so world y maps 1:1 to viewport y,
#     i.e. screen y = world y * 2 in the render.
#   - player.gd:_ready() builds an 18x28 RectangleShape2D at offset (0,-14), so the collider
#     spans 36x56 render pixels with its bottom edge on the player's feet.

Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dir  = Join-Path $root "evidence\screens\character"
if (-not (Test-Path (Join-Path $dir "beacon-right-standing.png"))) {
    throw "Frames not found in $dir. Run capture_character.gd first."
}

$PLAYER_X     = 440.0
$GROUNDED_FEET = 319.9253 * 2
$AIRBORNE_FEET = 273.5242 * 2

function New-Sheet($items, $cw, $ch, $scale, $cols, $dest, $drawCollider) {
    $tw = $cw * $scale; $th = $ch * $scale; $lab = 34
    $rows = [math]::Ceiling($items.Count / $cols)
    $sheet = New-Object System.Drawing.Bitmap (($tw * $cols), (($th + $lab) * $rows))
    $g = [System.Drawing.Graphics]::FromImage($sheet)
    $g.Clear([System.Drawing.Color]::White)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $font = New-Object System.Drawing.Font "Consolas", 17, ([System.Drawing.FontStyle]::Bold)
    $pen  = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 230, 20, 60)), 3
    for ($i = 0; $i -lt $items.Count; $i++) {
        $it = $items[$i]
        $col = $i % $cols; $row = [math]::Floor($i / $cols)
        $img = [System.Drawing.Image]::FromFile((Join-Path $dir "$($it.f).png"))
        $ox = $PLAYER_X - $cw / 2
        $oy = $it.feet - $ch + 18
        $destRect = New-Object System.Drawing.Rectangle ($col * $tw), ($row * ($th + $lab) + $lab), $tw, $th
        $srcRect  = New-Object System.Drawing.Rectangle $ox, $oy, $cw, $ch
        $g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
        if ($drawCollider) {
            $bx = ($PLAYER_X - 18 - $ox) * $scale + $col * $tw
            $by = ($it.feet - 56 - $oy) * $scale + $row * ($th + $lab) + $lab
            $g.DrawRectangle($pen, $bx, $by, (36 * $scale), (56 * $scale))
        }
        $g.DrawString($it.l, $font, [System.Drawing.Brushes]::Black, ($col * $tw + 8), ($row * ($th + $lab) + 7))
        $g.DrawRectangle([System.Drawing.Pens]::LightGray, $destRect)
        $img.Dispose()
    }
    $g.Dispose()
    $sheet.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $sheet.Dispose()
    Write-Host "wrote $dest"
}

$states = @(
    @{ f = "beacon-right-standing"; feet = $GROUNDED_FEET; l = "RIGHT / STANDING" },
    @{ f = "beacon-right-walking";  feet = $GROUNDED_FEET; l = "RIGHT / WALKING"  },
    @{ f = "beacon-right-jumping";  feet = $AIRBORNE_FEET; l = "RIGHT / JUMPING"  },
    @{ f = "beacon-left-standing";  feet = $GROUNDED_FEET; l = "LEFT / STANDING"  },
    @{ f = "beacon-left-walking";   feet = $GROUNDED_FEET; l = "LEFT / WALKING"   },
    @{ f = "beacon-left-jumping";   feet = $AIRBORNE_FEET; l = "LEFT / JUMPING"   })
New-Sheet $states 110 95 5 3 (Join-Path $dir "SHEET-beacon-states.png") $false

$collider = @(
    @{ f = "beacon-right-standing"; feet = $GROUNDED_FEET; l = "STANDING  feet y=319.93" },
    @{ f = "beacon-right-jumping";  feet = $AIRBORNE_FEET; l = "JUMPING   feet y=273.52" },
    @{ f = "beacon-left-standing";  feet = $GROUNDED_FEET; l = "LEFT      feet y=319.93" })
New-Sheet $collider 100 90 6 3 (Join-Path $dir "SHEET-collider-check.png") $true
