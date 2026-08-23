cd /opt/netbox/netbox
source /opt/netbox-4.6.2/venv/bin/activate
pip install -e /opt/netbox-pve-sync
python manage.py migrate pve_sync_plugin
python manage.py collectstatic --no-input
sudo systemctl restart netbox netbox-rq
systemctl status netbox netbox-rq
