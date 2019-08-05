sudo rm -rf /usr/sbin/shellac
sudo ln -s ~/bin/utils/ssh-chrome-extension/run /usr/sbin/shellac

sudo rm -rf /etc/systemd/system/shellac.service
sudo ln -s ~/bin/utils/ssh-chrome-extension/shellac.service /etc/systemd/system/shellac.service
sudo systemctl daemon-reload
sudo systemctl enable shellac
sudo systemctl restart shellac
