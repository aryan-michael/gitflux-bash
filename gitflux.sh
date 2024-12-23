#!/bin/bash

store_account() {
	echo -n "Enter the git username for this account: "
	read -r git_address
	echo -n "Enter the email address for this account: "
	read -r git_email

	echo "$git_address=$git_email" >> "$CONFIG_FILE"
}

CONFIG_FILE=~/.config/gitflux/config

if [ ! -f "$CONFIG_FILE" ]; then
	mkdir -p ~/.config/gitflux
	touch "$CONFIG_FILE"
	echo "No config file found. Let's set it up!"

	while true; do
		store_account
		echo -n "Add another account? (y/n)"
		read -r add_accounts
		if [ "$add_accounts" != "y" ]; then
			break
		fi
	done
fi

switch_account() {
	echo -n "Enter the git account to switch to: "
	read -r target_account
	
	while IFS='=' read -r key value; do
		if [ "$key" = "$target_account" ]; then
			ssh-add -D
			ssh-add ~/.ssh/"$target_account"
			git config --global user.name "$target_account"
			git config --global user.email "$value"
			echo "Successfully switched to account: $target_account"
			return
		fi
	done < "$CONFIG_FILE"

	echo "Git user {"$target_account"} not among the existing users."

}

switch_account
