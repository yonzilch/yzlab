{lib, ...}: {
  system.activationScripts."hermes-skills-whitelist" = lib.stringAfter ["users"] ''
    S="/var/lib/hermes/.hermes/skills"
    [ -d "$S" ] || exit 0

    # 整类删除
    for cat in apple data-science diagramming dogfood domain email gaming gifs \
                inference-sh media mlops note-taking productivity \
                smart-home social-media yuanbao; do
      rm -rf "$S/$cat"
    done

    # creative：只保留 excalidraw、architecture-diagram
    find "$S/creative" -mindepth 1 -maxdepth 1 -type d \
      ! -name "excalidraw" ! -name "architecture-diagram" \
      -exec rm -rf {} +

    # autonomous-ai-agents：只保留 hermes-agent、kanban-codex-lane
    find "$S/autonomous-ai-agents" -mindepth 1 -maxdepth 1 -type d \
      ! -name "hermes-agent" ! -name "kanban-codex-lane" \
      -exec rm -rf {} +

    # research：只保留 arxiv、llm-wiki
    find "$S/research" -mindepth 1 -maxdepth 1 -type d \
      ! -name "arxiv" ! -name "llm-wiki" \
      -exec rm -rf {} +

    # red-teaming：只保留 godmode
    find "$S/red-teaming" -mindepth 1 -maxdepth 1 -type d \
      ! -name "godmode" \
      -exec rm -rf {} +
  '';
}
