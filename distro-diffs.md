## Distribution differences

|  |Fedora | Debian |
| --- | --- | --- |
| chrony service name | `chronyd.service` | `chrony.service` |
| chrony config file | `/etc/chrony.conf` | `/etc/chrony/chrony.conf` |
| chrony confdir | none | `/etc/chrony/conf.d` |
| chrony sourcedir | none | `/etc/chrony/sources.d` |
| ptp4l config file | `/etc/ptp4l.conf` | `/etc/linuxptp/ptp4l.conf` |
| ptp4l service | `ptp4l.service` | `ptp4l@.service` |
| phc2sys service | `phc2sys.service` | `phc2sys@.service` |
| phc2sys service Before | | `time-sync.target` |
| Environment files directory | `/etc/sysconfig` | `/etc/default` |

