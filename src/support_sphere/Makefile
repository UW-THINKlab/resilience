include .env
export

json_output := assets/app_config.json

.PHONY: config

config:
	@printf '{\n' > $(json_output)
	@printf '\t"supabaseUrl": "%s",\n' "$(SUPABASE_URL)" >> $(json_output)
	@printf '\t"supabaseAnonKey": "%s"\n' "$(SUPABASE_API_KEY)" >> $(json_output)
	@printf '}\n' >> $(json_output)