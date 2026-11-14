#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
SOURCE="${1:-$HOME/PROJETOS APPLE/RiggieSee/Package.swift}"
if [ ! -f "$SOURCE" ]; then
  echo "Nao encontrei Package.swift do RiggieSee em: $SOURCE"
  echo "Uso: bash setup.sh '/caminho/para/RiggieSee/Package.swift'"
  exit 1
fi
if [ -e Package.swift ]; then
  echo 'Package.swift ja existe. Nao sera sobrescrito.'
  exit 0
fi
python3 - "$SOURCE" <<'PY'
from pathlib import Path
import sys
source = Path(sys.argv[1]).read_text()
source = source.replace('RiggieSee', 'LittleWizard').replace('riggiesee', 'littlewizard').replace('Riggiesee','LittleWizard')
Path('Package.swift').write_text(source)
print('Package.swift criado a partir das dependencias funcionais do RiggieSee.')
PY
