# SecureCRT连接Linux很慢的问题

	vi /etc/ssh/sshd_config

	修改

	UseDNS no

	重启sshd服务

	service sshd restart

	或者

	systemctl restart sshd.service