# BloodSpot

BloodSpot is a database of gene expression profiles and transcriptional programs for healthy and malignant haematopoiesis, developed and maintained by the Unit for Genomic Medicine, MDxCORE, Rigshospitalet, Copenhagen.

## Publications

- **v1** — Bagger et al. (2016). *BloodSpot: a database of gene expression profiles and transcriptional programs for healthy and malignant haematopoiesis.* Nucleic Acids Research, 44(D1):D917–D924. [Link](https://academic.oup.com/nar/article/44/D1/D917/2502611)
- **v2** — Bagger, Kinalis, Rapin (2019). *BloodSpot: a database of healthy and malignant haematopoiesis updated with purified and single cell mRNA sequencing profiles.* Nucleic Acids Research, 47(D1):D881–D885. [Link](https://academic.oup.com/nar/article/47/D1/D881/5160974)
- **v3** — Gíslason et al. (2024). *BloodSpot 3.0: a database of gene and protein expression data in normal and malignant haematopoiesis.* Nucleic Acids Research, 52(D1):D1138–D1142. [Link](https://academic.oup.com/nar/article/52/D1/D1138/7337619)

## This repository

This repo holds the consolidated **v3.1** codebase, merged from two divergent legacy source trees (`bloodspot/` and `fobinf.com/`) into a single source of truth.

### Stack

Current (v3.1): PHP / LAMP.
Planned (v4): PostgreSQL + Tailwind + React + Node.

### Repository structure

- `www/` — public web root (PHP frontend, JS, CSS, D3 visualizations)
- `httpd-private/` — server-side libraries, templates, and database initialization scripts
- `de_sql_data/` — data exploration notebooks

### Data

Large dataset dumps (`.sql`, `.sql.gz`) and generated survival plot archives are **not** stored in this repository. They are hosted separately at [data.bloodspot.eu](https://data.bloodspot.eu/).

## Roadmap

See the [v4 roadmap](#) for planned architecture changes, including database refactor, user management, and interface redesign.

## Contact

Maintained by the Unit for Genomic Medicine, MDxCORE, Rigshospitalet, Copenhagen.
