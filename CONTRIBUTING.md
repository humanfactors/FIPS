# Contribution Guidelines

Thank you for showing interest in FIPS! We are excited to know you are interested in being apart of this community.

We welcome contributions great or small from the community. Please do note that given the project is still in infancy,
we would appreciate if you could contact us prior to submitting a large pull request. This is to ensure that we aren't
doubling up on development efforts, and also we would love to hear from you!

Currently we are a young project, maintained by a small team (_n_ = 3). Our primary focus over 2020 is expanding the
FIPS user base. It would _incredibly_ useful to receive feedback via Github Issues for anything regarding the package,
including: installation issues, bugs or unexpected behaviour, usability, feature requests or inquiries, or even
something you don't understand in the tutorials about this class of models more generally. See specific details for each
of these requests below:

**Reporting a Bug:** If something has gone wrong with FIPS, would are grateful for your time to report the issue. Please
use the provided "bug report template" when filing an issue. Please try to provide a minimal reproducible example (e.g.,
via the suggested `reprex` package) where possible.

**General BMM Questions:** If you have any general questions about the biomathematical models implemented in this
package feel free to open a issue. We understand BMMs are a relatively novel class of models, and real research and
practice circumstances often demand solutions beyond existing papers. Please do read the package documentation first,
but it is useful for us to know if more information is required.

**Data Importing:** A particular area where contributions would be appreciated is sleep data formats. If you have a
relatively standard sleep data in a format that you are unable to import into FIPS, please do file an issue. While we
cannot promise the resources to ensure your exact format is supported in FIPS, we will endeavor to do so, and warmly
welcome collaborations aimed at expanding the supported data types.

**Feature Requests:** We also welcome feature requests, but would kindly ask for citations/references to any requests
for technical implementations.

## Pull Requests & Code Conventions

As mentioned, we would appreciate if you could contact us prior to submitting a large pull request. In particular, if
you are interested in adding support for another form of BMM, please do reach out as this would prompt us to develop
guidelines for adding models.

A brief list of coding conventions, which are somewhat atypical:

- Hard wrap source files to a 120 line margin (excluding comments or strings senstive to newlines)
- Markdown files should be either unwrapped or 'filled' to 100 or 120 line margin in Emacs.
- We use `<-` for function assignment, and `=` for variable assignment.
- Underscores (i.e., snake-case) should separate words in object names. Period separation is currently used for legacy supported functions.
- When naming objects, abbreviations and parameter names should use capitals as a first priority (e.g., `TPM_make_pvec` not `tpm_make_pvec`; but `unified_make_pvec` is fine).

Development should be conducted on a separate branch. Tests are run using the `testthat` package automatically with Rstudio default.
This can be invoked by pressing `ctrl + shift + T` in Windows or Linux. `roxygen2` is used for all documentation.

Thankyou!
