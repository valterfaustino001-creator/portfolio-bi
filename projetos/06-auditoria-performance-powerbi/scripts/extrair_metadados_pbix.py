"""
Extrai metadados de um arquivo .pbix sem abrir o Power BI Desktop.

Uso:
    pip install pbixray pandas
    python extrair_metadados_pbix.py MeuRelatorio.pbix saida/

Gera CSVs com: schema, medidas DAX, colunas e tabelas calculadas,
relacionamentos, consultas Power Query, parâmetros M e estatísticas
de tamanho e cardinalidade. Também lista páginas e visuais do relatório.
"""
from __future__ import annotations

import collections
import json
import sys
import zipfile
from pathlib import Path

from pbixray import PBIXRay

ATRIBUTOS = [
    "schema", "dax_measures", "dax_columns", "dax_tables",
    "relationships", "power_query", "m_parameters", "statistics",
]


def extrair_modelo(pbix: Path, saida: Path) -> None:
    modelo = PBIXRay(str(pbix))
    for nome in ATRIBUTOS:
        df = getattr(modelo, nome)
        df.to_csv(saida / f"{nome}.csv", index=False)
        print(f"{nome:15} {len(df):>6} linhas")
    auto = [t for t in modelo.tables if str(t).startswith(("LocalDateTable", "DateTableTemplate"))]
    print(f"Tabelas de data automáticas (Auto Date/Time): {len(auto)}")


def listar_paginas(pbix: Path) -> None:
    """Suporta o formato antigo (Report/Layout) e o novo PBIR (Report/definition)."""
    z = zipfile.ZipFile(pbix)
    nomes = z.namelist()
    if "Report/Layout" in nomes:
        layout = json.loads(z.read("Report/Layout").decode("utf-16-le"))
        for s in layout["sections"]:
            print(f"- {s['displayName']}: {len(s.get('visualContainers', []))} visuais")
    elif "Report/definition/pages/pages.json" in nomes:
        ordem = json.loads(z.read("Report/definition/pages/pages.json"))["pageOrder"]
        for pid in ordem:
            pagina = json.loads(z.read(f"Report/definition/pages/{pid}/page.json"))
            tipos = collections.Counter(
                json.loads(z.read(n)).get("visual", {}).get("visualType", "grupo")
                for n in nomes
                if n.startswith(f"Report/definition/pages/{pid}/visuals/") and n.endswith("visual.json")
            )
            print(f"- {pagina['displayName']}: {dict(tipos)}")


if __name__ == "__main__":
    arquivo, pasta = Path(sys.argv[1]), Path(sys.argv[2])
    pasta.mkdir(parents=True, exist_ok=True)
    extrair_modelo(arquivo, pasta)
    listar_paginas(arquivo)
