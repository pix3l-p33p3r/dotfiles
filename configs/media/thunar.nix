{ pkgs, config, lib, ... }:
{
  # NixOS services.gvfs sets this globally, but Hyprland/SDDM sessions often skip
  # login profile; without it Thunar cannot load trash:// computer:// sftp:// backends.
  home.sessionVariables.GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";
  systemd.user.sessionVariables.GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules";

  # ============================================================================
  # |                      THUNAR FILE MANAGER - PACKAGES                    |
  # ============================================================================
  home.packages = with pkgs; [
    # Thunar File Manager
    thunar

    # Official XFCE Thunar Plugins
    thunar-archive-plugin # Create and extract archives
    thunar-media-tags-plugin # ID3 tags and media metadata support
    thunar-volman # Automatic management of removable devices

    # Thumbnail Generator
    tumbler # Remote thumbnail service for Thunar
    ffmpegthumbnailer # Video thumbnails for Tumbler

    # GVFS (also requires NixOS services.gvfs.enable for D-Bus + GIO_EXTRA_MODULES)
    gvfs # Trash, removable media, smb:// ftp:// … (Thunar checks this at runtime)

    # Archive Frontend for thunar-archive-plugin
    xarchiver # Provides create/extract UI used by thunar-archive-plugin

    # Icon Theming
    papirus-folders # Papirus folder recoloring tool

    # Additional utilities for custom actions (also on PATH; uca.xml uses store paths)
    file # File type identification
    exiftool
    mat2
    picocrypt
  ];

  # Thumbnailer is enabled at system level (services.tumbler)

  # ============================================================================
  # |                    THUNAR DECLARATIVE CONFIGURATION                    |
  # ============================================================================

  # Main Thunar configuration file (thunarrc)
  xdg.configFile."Thunar/thunarrc".text = ''
    [Configuration]
    # Default view mode (ThunarIconView, ThunarDetailsView, ThunarCompactView)
    DefaultView=ThunarDetailsView
    LastView=ThunarDetailsView
    
    # Show hidden and backup files
    LastShowHidden=FALSE
    
    # Sorting
    LastSortColumn=THUNAR_COLUMN_NAME
    LastSortOrder=GTK_SORT_ASCENDING
    LastDetailsViewColumnOrder=THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE,THUNAR_COLUMN_DATE_MODIFIED
    LastDetailsViewColumnWidths=50,50,50,50
    LastDetailsViewFixedColumns=TRUE
    LastDetailsViewVisibleColumns=THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE
    
    # Icon view zoom level (THUNAR_ZOOM_LEVEL_*: 25, 38, 50, 75, 100, 150, 200, 300, 400)
    LastIconViewZoomLevel=THUNAR_ZOOM_LEVEL_100
    
    # Window geometry
    LastWindowWidth=900
    LastWindowHeight=600
    LastWindowMaximized=FALSE
    LastSeparatorPosition=170
    
    # Side pane settings (ThunarShortcutsPane or ThunarTreePane)
    LastSidePane=ThunarShortcutsPane
    
    # Location bar style (ThunarLocationButtons or ThunarLocationEntry)
    LastLocationBar=ThunarLocationButtons
    
    # Statusbar
    LastStatusbarVisible=TRUE
    LastMenubarVisible=TRUE
    
    # Behavior
    MiscVolumeManagement=TRUE
    MiscCaseSensitive=FALSE
    MiscDateStyle=THUNAR_DATE_STYLE_SIMPLE
    MiscFoldersFirst=TRUE
    MiscHorizontalWheelNavigates=FALSE
    MiscRecursivePermissions=THUNAR_RECURSIVE_PERMISSIONS_ASK
    MiscRememberGeometry=TRUE
    MiscShowAboutTemplates=TRUE
    MiscShowThumbnails=TRUE
    MiscSingleClick=FALSE
    MiscSingleClickTimeout=500
    MiscTextBesideIcons=FALSE
    
    # Thumbnail settings
    MiscThumbnailMode=THUNAR_THUMBNAIL_MODE_ALWAYS
    MiscThumbnailDrawFrames=TRUE
    
    # File transfer settings
    MiscTransferVerifyFile=TRUE
    MiscFileTransferAccelerator=<Primary><Shift>c
    
    # Advanced
    MiscFullPathInTitle=FALSE
    MiscParallelCopyMode=THUNAR_PARALLEL_COPY_MODE_ALWAYS
    MiscConfirmClose=TRUE
    MiscConfirmMoveToTrash=TRUE
    
    # Tree view
    ShortcutsIconEmblems=TRUE
    ShortcutsIconSize=THUNAR_ICON_SIZE_SMALLEST
    TreeIconEmblems=TRUE
    TreeIconSize=THUNAR_ICON_SIZE_SMALLEST
  '';

  # ============================================================================
  # |                     THUNAR CUSTOM ACTIONS (UCA)                        |
  # ============================================================================

  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
      <!-- Open Terminal Here -->
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu></submenu>
        <unique-id>1234567890123456-1</unique-id>
        <command>${pkgs.kitty}/bin/kitty --working-directory %f</command>
        <description>Open a terminal in the selected folder</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
      </action>
      
      <!-- Open as Root -->
      <action>
        <icon>system-run</icon>
        <name>Open as Root</name>
        <submenu></submenu>
        <unique-id>1234567890123456-2</unique-id>
        <command>pkexec ${pkgs.thunar}/bin/thunar %f</command>
        <description>Open folder with root privileges</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
      </action>
      
      <!-- Edit as Root -->
      <action>
        <icon>text-editor</icon>
        <name>Edit as Root</name>
        <submenu></submenu>
        <unique-id>1234567890123456-3</unique-id>
        <command>pkexec nvim %f</command>
        <description>Edit file with root privileges</description>
        <range></range>
        <patterns>*</patterns>
        <text-files/>
      </action>
      
      <!-- File/Directory Properties -->
      <action>
        <icon>dialog-information</icon>
        <name>File Information</name>
        <submenu></submenu>
        <unique-id>1234567890123456-4</unique-id>
        <command>${pkgs.file}/bin/file -b %f | ${pkgs.kitty}/bin/kitty --hold --title "File Info: %n"</command>
        <description>Show detailed file information</description>
        <range></range>
        <patterns>*</patterns>
        <other-files/>
      </action>
      
      <!-- View EXIF Data -->
      <action>
        <icon>camera-photo</icon>
        <name>View EXIF Data</name>
        <submenu></submenu>
        <unique-id>1234567890123456-5</unique-id>
        <command>${pkgs.exiftool}/bin/exiftool %f | ${pkgs.less}/bin/less</command>
        <description>View image EXIF metadata</description>
        <range></range>
        <patterns>*.jpg;*.jpeg;*.png;*.tiff;*.raw;*.cr2;*.nef</patterns>
        <image-files/>
      </action>
      
      <!-- Copy Path -->
      <action>
        <icon>edit-copy</icon>
        <name>Copy Path</name>
        <submenu></submenu>
        <unique-id>1234567890123456-6</unique-id>
        <command>echo -n %f | ${pkgs.wl-clipboard}/bin/wl-copy</command>
        <description>Copy full path to clipboard</description>
        <range></range>
        <patterns>*</patterns>
        <directories/>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
      
      <!-- Calculate Checksum (SHA256) -->
      <action>
        <icon>utilities-system-monitor</icon>
        <name>Calculate SHA256</name>
        <submenu></submenu>
        <unique-id>1234567890123456-7</unique-id>
        <command>${pkgs.kitty}/bin/kitty --hold sh -c '${pkgs.coreutils}/bin/sha256sum %f'</command>
        <description>Calculate SHA256 checksum</description>
        <range></range>
        <patterns>*</patterns>
        <other-files/>
      </action>
      
      <!-- Set as Wallpaper (for images) -->
      <action>
        <icon>preferences-desktop-wallpaper</icon>
        <name>Set as Wallpaper</name>
        <submenu></submenu>
        <unique-id>1234567890123456-8</unique-id>
        <command>${pkgs.hyprpaper}/bin/hyprpaper -c "preload %f; wallpaper ,,%f"</command>
        <description>Set image as wallpaper</description>
        <range></range>
        <patterns>*.jpg;*.jpeg;*.png;*.webp</patterns>
        <image-files/>
      </action>
      
      <!-- Compress to tar.gz -->
      <action>
        <icon>package-x-generic</icon>
        <name>Compress (tar.gz)</name>
        <submenu></submenu>
        <unique-id>1234567890123456-9</unique-id>
        <command>${pkgs.kitty}/bin/kitty --hold sh -c '${pkgs.gnutar}/bin/tar -czf %n.tar.gz %n &amp;&amp; echo "Created: %n.tar.gz"'</command>
        <description>Compress to tar.gz archive</description>
        <range></range>
        <patterns>*</patterns>
        <directories/>
      </action>
      
      <!-- Search with ripgrep -->
      <action>
        <icon>system-search</icon>
        <name>Search in Files</name>
        <submenu></submenu>
        <unique-id>1234567890123456-10</unique-id>
        <command>${pkgs.kitty}/bin/kitty sh -c 'cd %f &amp;&amp; read -p "Search for: " query &amp;&amp; ${pkgs.ripgrep}/bin/rg -i "$query" | ${pkgs.less}/bin/less'</command>
        <description>Search for text in files using ripgrep</description>
        <range></range>
        <patterns>*</patterns>
        <directories/>
      </action>

      <!-- ============================================================ -->
      <!-- Security submenu actions                                     -->
      <!-- ============================================================ -->

      <!-- Secure Delete (rm + immediate TRIM) -->
      <action>
        <icon>edit-delete</icon>
        <name>Secure Delete</name>
        <submenu>Security</submenu>
        <unique-id>1234567890123456-11</unique-id>
        <command>${pkgs.kitty}/bin/kitty --hold sh -c 'echo "WARNING: This will permanently destroy the following file:" &amp;&amp; echo "  %n" &amp;&amp; echo "" &amp;&amp; echo "The NVMe will be told to wipe the freed blocks immediately." &amp;&amp; echo "There is NO recovery after this." &amp;&amp; echo "" &amp;&amp; printf "Type YES to confirm: " &amp;&amp; read confirm &amp;&amp; if [ "$confirm" = "YES" ]; then rm -f %f &amp;&amp; sudo ${pkgs.util-linux}/bin/fstrim -v / &amp;&amp; echo "" &amp;&amp; echo "Done. File destroyed and blocks trimmed."; else echo "Aborted."; fi'</command>
        <description>Delete file and immediately TRIM freed NVMe blocks</description>
        <range></range>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <!-- Strip Metadata (mat2) -->
      <action>
        <icon>document-edit</icon>
        <name>Strip Metadata</name>
        <submenu>Security</submenu>
        <unique-id>1234567890123456-12</unique-id>
        <command>${pkgs.kitty}/bin/kitty --hold sh -c '${pkgs.mat2}/bin/mat2 %f &amp;&amp; echo "" &amp;&amp; echo "Metadata stripped. Clean copy created alongside original."'</command>
        <description>Remove all metadata from file (creates .cleaned copy)</description>
        <range></range>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <!-- GPG Sign (detached, armored) -->
      <action>
        <icon>channel-secure-symbolic</icon>
        <name>GPG Sign</name>
        <submenu>Security</submenu>
        <unique-id>1234567890123456-13</unique-id>
        <command>${pkgs.kitty}/bin/kitty --hold sh -c '${pkgs.gnupg}/bin/gpg --armor --detach-sign %f &amp;&amp; echo "" &amp;&amp; echo "Signature created: %n.asc"'</command>
        <description>Create a detached GPG signature (.asc)</description>
        <range></range>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>

      <!-- Encrypt with Picocrypt -->
      <action>
        <icon>security-high</icon>
        <name>Encrypt (Picocrypt)</name>
        <submenu>Security</submenu>
        <unique-id>1234567890123456-14</unique-id>
        <command>${pkgs.picocrypt}/bin/picocrypt %f</command>
        <description>Encrypt file with Picocrypt (AES-256)</description>
        <range></range>
        <patterns>*</patterns>
        <audio-files/>
        <image-files/>
        <other-files/>
        <text-files/>
        <video-files/>
      </action>
    </actions>
  '';

  # ============================================================================
  # |                    THUNAR VOLUME MANAGER CONFIG                        |
  # ============================================================================
  
  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar-volman.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="thunar-volman" version="1.0">
      <property name="automount-drives" type="empty">
        <property name="enabled" type="bool" value="true"/>
      </property>
      <property name="automount-media" type="empty">
        <property name="enabled" type="bool" value="true"/>
      </property>
      <property name="autoopen" type="bool" value="true"/>
      <property name="autoplay-audio-cds" type="empty">
        <property name="enabled" type="bool" value="false"/>
      </property>
      <property name="autoplay-video-cds" type="empty">
        <property name="enabled" type="bool" value="false"/>
      </property>
      <property name="autorun" type="bool" value="false"/>
      <property name="autobrowse" type="bool" value="true"/>
    </channel>
  '';

  # ============================================================================
  # |                     TUMBLER THUMBNAIL SERVICE                          |
  # ============================================================================
  
  xdg.configFile."tumbler/tumbler.rc".text = ''
    [Cache]
    # Maximum cache size in bytes (500MB)
    MaxCacheSize=524288000
    # Cache lifetime in days
    MaxCacheAge=90
    
    [Thumbnailers]
    # Enable all thumbnailers
    Disabled=
  '';
}
