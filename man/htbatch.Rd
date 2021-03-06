% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/htbatch.R
\name{htbatch}
\alias{htbatch}
\title{Batch search and match of fragment sigma values}
\usage{
htbatch(file, sigma.selection = "A", ...)
}
\arguments{
\item{file}{path to csv file}

\item{sigma.selection}{The type of sigma to be returned; valid inputs include "A", "B", "C", "D", "E", "F", "G", "H", and "U"}

\item{...}{inherit arguments}
}
\value{
Filled dataframe columns resulting from similarity search and value extraction from
esSDF, indSDF, metaSDF, paraSDF, orthoSDF, taftSDF, userSDF
}
\description{
Get values of Hammett-Taft descriptors for a given chemical fragment in SMILES string format by iterating through a lookup table. In case an exact match isnt found, this function uses a mismatch tolerant
maximum common substructure (fMCS) based fragment substitution library to get the HT dexcriptors with highest tanimoto coefficient. This function iterates through a loop to complete a batch file of sigma
values.
}
\examples{
## NOT RUN: htbatch("./data/dataacidester.csv", sigma.selection ="A")
}
