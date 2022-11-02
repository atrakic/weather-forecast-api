.PHONY: git-sync
git-sync:
	if [[ "$$(git config --get remote.origin.url)" == "git@github.com:atrakic/weather-forecast-api.git" ]]; then \
		git remote -v | grep -q upstream || git remote add upstream git@ssh.dev.azure.com:v3/aty0918/dev/dev; \
		git fetch upstream; \
		git checkout main; \
		git merge upstream/main --allow-unrelated-histories; \
		git push origin --tags; \
	fi
