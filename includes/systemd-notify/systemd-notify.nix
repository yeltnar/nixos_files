# man systemd-socket-proxyd
# https://askubuntu.com/questions/1120023/how-to-use-systemd-notify
{
  # config,
  pkgs,
  ...
}: {

  # after the service is started, run `echo somedata | sudo tee /tmp/waldo`

  systemd.services.systemd-notify-test = {
    description="test of manual systemd-notify";
    script = ''
      rm -f /tmp/waldo
      mkfifo /tmp/waldo
      sleep 3
      systemd-notify --ready --status="Waiting for data…"

      while : ; do
        read a < /tmp/waldo
        systemd-notify --status="Processing $a"

        # Do something with $a …
        sleep 3

        systemd-notify --status="Waiting for data again…"
      done
          '';
    serviceConfig = { 
      Type="notify";
    };
  };

}
