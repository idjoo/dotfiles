{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.rclone;
in
{
  options.modules.rclone = {
    enable = mkEnableOption "rclone";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rclone ];
    environment.etc."rclone-gdrive.conf".text = ''
      [gdrive]
      type = drive
      scope = drive,drive.readonly,drive.file,drive.appfolder,drive.metadata.readonly
      token = {"access_token":"ya29.a0AcM612xz5LlRUEqEelb-8SasKSkMzOn-NDkieRlwdZTbSeoxO28u7VepTBPiGseZXTMyZ8Md-dFy0mUzSS9jyQDRUQLZ5N3tY_p4nH9ip5KAmqqvisVMD0oFURnlYuxTLcKoaGzY5Jc41qqKuYKQjdOLAf40CP_TxL8PaCgYKARISARESFQHGX2MiFTOPZARkbkLSO322BCoh8Q0171","token_type":"Bearer","refresh_token":"1//0gxK7TC_DuBtDCgYIARAAGBASNwF-L9IrdmwX67vMAlw7aKoIuJDCFOEffuYIo9narzI_yC7fUavA4ZaG4O1r-zFmfEtTr7J5DbM","expiry":"2024-08-13T21:59:55.36079462+07:00"}
      export_formats = docx,xlsx,pptx,svg

      [gdrive-shared]
      type = drive
      scope = drive,drive.readonly,drive.file,drive.appfolder,drive.metadata.readonly
      token = {"access_token":"ya29.a0AcM612xz5LlRUEqEelb-8SasKSkMzOn-NDkieRlwdZTbSeoxO28u7VepTBPiGseZXTMyZ8Md-dFy0mUzSS9jyQDRUQLZ5N3tY_p4nH9ip5KAmqqvisVMD0oFURnlYuxTLcKoaGzY5Jc41qqKuYKQjdOLAf40CP_TxL8PaCgYKARISARESFQHGX2MiFTOPZARkbkLSO322BCoh8Q0171","token_type":"Bearer","refresh_token":"1//0gxK7TC_DuBtDCgYIARAAGBASNwF-L9IrdmwX67vMAlw7aKoIuJDCFOEffuYIo9narzI_yC7fUavA4ZaG4O1r-zFmfEtTr7J5DbM","expiry":"2024-08-13T21:59:55.36079462+07:00"}
      shared_with_me = true
      export_formats = docx,xlsx,pptx,svg
    '';

    fileSystems."/home/idjo/documents/drive/my-drive" = {
      device = "gdrive:/";
      fsType = "rclone";
      options = [
        "nodev"
        "nofail"
        "allow_other"
        "args2env"
        "uid=1000"
        "gid=100"
        "config=/etc/rclone-gdrive.conf"
      ];
    };

    fileSystems."/home/idjo/documents/drive/shared-with-me" = {
      device = "gdrive-shared:/";
      fsType = "rclone";
      options = [
        "nodev"
        "nofail"
        "allow_other"
        "args2env"
        "uid=1000"
        "gid=100"
        "config=/etc/rclone-gdrive.conf"
      ];
    };
  };
}
