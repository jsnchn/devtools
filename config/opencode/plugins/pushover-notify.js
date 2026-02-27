export const PushoverNotify = async ({ project, client, $, directory, worktree }) => {
	const scriptPath = `${process.env.HOME}/bin/pushover.sh`

	let tmuxSession = "no-tmux"
	let machineHostname = "unknown-host"
	let baseUrl = ""

	try {
		tmuxSession = (await $`tmux display-message -p '#S' 2>/dev/null`).trim() || "no-tmux"
	} catch {
		tmuxSession = "no-tmux"
	}

	try {
		machineHostname = (await $`hostname`.trim()) || "unknown-host"
	} catch {
		machineHostname = "unknown-host"
	}

	if (tmuxSession !== "no-tmux" && machineHostname !== "unknown-host") {
		baseUrl = `https://${machineHostname}.tailscale.net:8080/${tmuxSession}`
	}

	const notify = async (title, message, priority = 0, url = "", urlTitle = "") => {
		await $`"$scriptPath" "$title" "$message" "$url" "$urlTitle" "$priority"`
	}

	return {
		event: async ({ event }) => {
			switch (event.type) {
				case "session.idle": {
					const projectName = worktree || directory || "unknown"
					await notify(
						`OpenCode [${tmuxSession}]`,
						`Session completed in ${projectName}`,
						-1,
						baseUrl,
						"Open tmux session"
					)
					break
				}
				case "session.error": {
					const errMsg = event.error?.message || event.message || "Unknown error"
					await notify(
						`OpenCode [${tmuxSession}]`,
						`Error: ${errMsg}`,
						1,
						baseUrl,
						"Open tmux session"
					)
					break
				}
				case "tui.prompt.append": {
					const prompt = event.prompt || event.message || "Question"
					await notify(
						`OpenCode [${tmuxSession}]`,
						`Question: ${prompt.substring(0, 200)}`,
						0,
						baseUrl,
						"Open tmux session"
					)
					break
				}
				case "permission.asked": {
					const perm = event.permission || event.tool || "permission"
					await notify(
						`OpenCode [${tmuxSession}]`,
						`Permission needed: ${perm}`,
						0,
						baseUrl,
						"Open tmux session"
					)
					break
				}
				case "tui.toast.show": {
					const toast = event.message || event.text || ""
					if (toast) {
						await notify(
							`OpenCode [${tmuxSession}]`,
							`Notification: ${toast.substring(0, 200)}`,
							-1,
							baseUrl,
							"Open tmux session"
						)
					}
					break
				}
			}
		},
	}
}
