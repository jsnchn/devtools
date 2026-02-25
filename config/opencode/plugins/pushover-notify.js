export const PushoverNotify = async ({ project, client, $, directory, worktree }) => {
	const notify = async (title, message) => {
		const scriptPath = `${process.env.HOME}/bin/pushover.sh`
		await $`"$scriptPath" "$message" "$title"`
	}

	return {
		event: async ({ event }) => {
			switch (event.type) {
				case "session.idle": {
					const projectName = worktree || directory || "unknown"
					await notify("OpenCode: Complete", `Session finished in ${projectName}`)
					break
				}
				case "session.error": {
					const errMsg = event.error?.message || event.message || "Unknown error"
					await notify("OpenCode: Error", errMsg)
					break
				}
				case "tui.prompt.append": {
					const prompt = event.prompt || event.message || "Question"
					await notify("OpenCode: Question", prompt.substring(0, 200))
					break
				}
				case "permission.asked": {
					const perm = event.permission || event.tool || "permission"
					await notify("OpenCode: Permission", `Need: ${perm}`)
					break
				}
				case "tui.toast.show": {
					const toast = event.message || event.text || ""
					if (toast) {
						await notify("OpenCode", toast.substring(0, 200))
					}
					break
				}
			}
		},
	}
}
