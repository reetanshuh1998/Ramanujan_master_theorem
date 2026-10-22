"""Sphinx configuration for the ramanujan-qft documentation site."""
import os
import sys
from datetime import date

sys.path.insert(0, os.path.abspath(".."))

import ramanujan_qft  # noqa: E402

project = "ramanujan-qft"
author = "Reet"
copyright = f"{date.today().year}, ramanujan-qft contributors. In memory of Srinivasa Ramanujan"
release = ramanujan_qft.__version__
version = ".".join(release.split(".")[:2])

extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.autosummary",
    "sphinx.ext.napoleon",
    "sphinx.ext.mathjax",
    "sphinx.ext.viewcode",
    "myst_parser",
    "sphinx_design",
    "sphinx_copybutton",
    "sphinx_gallery.gen_gallery",
]

source_suffix = {".rst": "restructuredtext", ".md": "markdown"}
myst_enable_extensions = ["colon_fence", "dollarmath", "amsmath", "deflist", "attrs_block", "attrs_inline"]
myst_heading_anchors = 3

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store", "**.ipynb_checkpoints"]

autodoc_default_options = {"members": True, "show-inheritance": False}
autodoc_member_order = "bysource"
autosummary_generate = True
napoleon_numpy_docstring = True
napoleon_google_docstring = False


sphinx_gallery_conf = {
    "examples_dirs": "../examples",
    "gallery_dirs": "auto_examples",
    "filename_pattern": r"/\d\d_",          # execute every numbered example
    "abort_on_example_error": True,
    "download_all_examples": False,
    "remove_config_comments": True,
    "write_computation_times": False,
}

copybutton_prompt_text = r">>> |\.\.\. |\$ "
copybutton_prompt_is_regexp = True

html_theme = "pydata_sphinx_theme"
html_title = "ramanujan-qft"
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_baseurl = "https://reetanshuh1998.github.io/Ramanujan_master_theorem/"
html_theme_options = {
    "github_url": "https://github.com/reetanshuh1998/Ramanujan_master_theorem",
    "logo": {"text": "ramanujan-qft"},
    "navbar_align": "left",
    "header_links_before_dropdown": 6,
    "show_toc_level": 2,
    "navigation_with_keys": False,
    "footer_start": ["copyright"],
    "footer_end": ["sphinx-version"],
}
html_context = {"default_mode": "auto"}
# single pages without sub-pages: no (empty) section navigation on the left
html_sidebars = {page: [] for page in ("index", "try_it", "validation", "COMPARISON", "PRIOR_ART",
                                       "citing", "changelog")}
