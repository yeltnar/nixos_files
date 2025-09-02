{
  config,
  pkgs,
  ...
}: {
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/1 * * * *      drew    date >> /tmp/cron.log"
    ];
  };
}
