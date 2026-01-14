# QuantumZero
The QuantumZero repository hosts the project’s public-facing static website, delivered through GitLab Pages. This site provides high-level information about the platform, including architectural overviews, user workflows, and integration guidance for external stakeholders. It serves as the central communication point for users, developers, and third-party partners, offering clear, accessible documentation separate from the system’s source code.

## Primary Contents
- Project overview and conceptual documentation
- Architecture summaries (DIDs, VCs, ZKPs, trust registry)
- User onboarding materials and FAQs
- API references and integration guides
- Visual diagrams and system walkthroughs
- Static HTML/CSS/JavaScript assets
- Links to mobile and server repositories

## Rationale
Separating the static site into its own repository simplifies maintenance, enables continuous updates without affecting the application codebases, and aligns with best practices for developer-facing identity platforms (e.g., Auth0, SpruceID). It also allows the team to maintain formal CSC688 documentation and public presentation resources in one centralized, easily distributable location.

## Diagram Generation

### PlantUML Diagrams
PlantUML diagrams (`.puml` files) can be rendered to PNG or SVG using the PlantUML JAR. First, ensure you have Java installed, then download `plantuml.jar` from [https://plantuml.com/download](https://plantuml.com/download).

Generate PNG images (3840x2160, transparent background):
```powershell
Get-ChildItem -Filter *.puml | ForEach-Object {
    java -jar plantuml.jar `
      -o "..\diagrams-png" `
      -tpng `
      -charset UTF-8 `
      $_.FullName
}
```

Generate SVG images:
```powershell
Get-ChildItem -Filter *.puml | ForEach-Object {
    java -jar plantuml.jar `
      -o "..\diagrams-svg" `
      -tsvg `
      -charset UTF-8 `
      $_.FullName
}
```

### Mermaid Diagrams (Legacy)
Mermaid diagrams (`.mmd` files) can be rendered using `mmdc` (Mermaid CLI):
```powershell
Get-ChildItem -Filter *.mmd | ForEach-Object {
    mmdc `
      -i $_.FullName `
      -o "..\diagrams-png\$($_.BaseName).png" `
      --width 3840 `
      --height 2160 `
      --backgroundColor transparent
}
```
