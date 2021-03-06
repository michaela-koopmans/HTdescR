
#' HTbatch
#'
#' Batch search and match of fragment sigma values
#'
#' Get values of Hammett-Taft descriptors for a given chemical fragment in SMILES string format by iterating through a lookup table. In case an exact match isnt found, this function uses a mismatch tolerant
#' maximum common substructure (fMCS) based fragment substitution library to get the HT dexcriptors with highest tanimoto coefficient. This function iterates through a loop to complete a batch file of sigma
#' values.
#'
#' @usage htbatch(file, sigma.selection = "A", ...)
#'
#'
#' @param file path to csv file
#' @param sigma.selection The type of sigma to be returned; valid inputs include "A", "B", "C", "D", "E", "F", "G", "H", and "U"
#' @param ... Arguments to be passed to fmcsR::fmcsBatch, such as al, au, bl, and bu
#'
#' @return Filled dataframe columns resulting from similarity search and value extraction from
#' esSDF, indSDF, metaSDF, paraSDF, orthoSDF, taftSDF, userSDF
#'
#' @import hash
#' @import utils
#' @import dplyr
#'
#' @export
#'
#' @examples
#' \dontrun{
#' htbatch("./inst/extdata/carbamateinputfile.csv", sigma.selection ="A")
#' }
htbatch <- function(file, sigma.selection = "A", ...) {

  #Initialize empty hash tables

  hash_taft <- hash::hash()
  hash_ind <- hash::hash()
  hash_es <- hash::hash()
  hash_meta <- hash::hash()
  hash_para <- hash::hash()
  hash_ortho <- hash::hash()

  #Read the csv file as a dataframe

  qsardataframe <- utils::read.csv(file, stringsAsFactors = FALSE, na.strings = "", encoding = "UTF-8")
  #qsardataframe <- qsardataframe %>% dplyr::mutate_all(dplyr::na_if, "")

  #colnames(qsardataframe)[colnames(qsardataframe)=="ï..no"] <- "no"

  #Initializing the iterator

  i <- 1
  n <- nrow (qsardataframe)

  for (i in 1:n) {
    # create value for hash table to save instead of "r1.taft.smiles[i]" character string
    taftsmiles1 <- qsardataframe$r1.taft.smiles[[i]]
    indsmiles1 <- qsardataframe$r1.ind.smiles[[i]]
    essmiles1 <- qsardataframe$r1.es.smiles[[i]]
    meta1smiles1 <- qsardataframe$r1.meta1.smiles[[i]]
    meta1smiles2 <- qsardataframe$r1.meta2.smiles[[i]]
    parasmiles1 <- qsardataframe$r1.para1.smiles[[i]]
    ortho1smiles1 <- qsardataframe$r1.ortho1.smiles[[i]]
    ortho1smiles2 <- qsardataframe$r1.ortho2.smiles[[i]]
    taftsmiles2 <- qsardataframe$r2.taft.smiles[[i]]
    indsmiles2 <- qsardataframe$r2.ind.smiles[[i]]
    essmiles2 <- qsardataframe$r2.es.smiles[[i]]
    meta2smiles1 <- qsardataframe$r2.meta1.smiles[[i]]
    meta2smiles2 <- qsardataframe$r2.meta2.smiles[[i]]
    parasmiles2 <- qsardataframe$r2.para1.smiles[[i]]
    ortho2smiles1 <- qsardataframe$r2.ortho1.smiles[[i]]
    ortho2smiles2 <- qsardataframe$r2.ortho2.smiles[[i]]

    if (is.na(qsardataframe$r1.meta1.smiles[i]) & is.na(qsardataframe$r1.ortho1.smiles[i]) & is.na(qsardataframe$r1.para1.smiles[i]) == TRUE) { #If structure does not have substitutions on aromatic ring on R1...

      if (is.na(taftsmiles1) == FALSE && hash::has.key(taftsmiles1, hash_taft) == TRUE) { #If taftsmiles exists and the key is already in the hash table...

        #Copy info already in hash table into output dataframe
        t <- hash_taft[[taftsmiles1]]
        qsardataframe$r1.taft.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.taft.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.taft.value[i] <- t$value
        rm (t)

      } else if (is.na(taftsmiles1) == FALSE) { #If taftsmiles exists but is NOT in hash table yet...

        #Perform search if info isn't already in hash table, then add info to output dataframe
        t <- htdesc (smile = qsardataframe$r1.taft.smiles[i], HT.type = "taft", sigma.selection, ...)

        hash_taft[[taftsmiles1]] <- t #Add to hash table

        qsardataframe$r1.taft.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.taft.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.taft.value[i] <- t$value
        rm (t)
      }

      if (is.na(indsmiles1) == FALSE && hash::has.key(indsmiles1, hash_ind) == TRUE) { #If indsmiles exists and is already in hash table...

        #Copy info already in hash table into output dataframe
        t <- hash_ind[[indsmiles1]]
        qsardataframe$r1.ind.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ind.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ind.value[i] <- t$value
        rm (t)


      } else if (is.na(indsmiles1) == FALSE) { #If indsmiles exists but is NOT already in hash table...

        #Perform search if info isn't already in hash table, then add info to output dataframe
        t <- htdesc (smile = qsardataframe$r1.ind.smiles[i], HT.type = "inductive", sigma.selection, ...)

        hash_ind[[indsmiles1]] <- t #Add to hash table

        qsardataframe$r1.ind.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ind.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ind.value[i] <- t$value
        rm (t)

      }

      if (is.na(essmiles1) == FALSE && hash::has.key(essmiles1, hash_es) == TRUE) { #If essmiles exists and is already in hash table...

        #Copy info already in hash table into output dataframe
        t <- hash_es[[essmiles1]]
        qsardataframe$r1.es.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.es.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.es.value[i] <- t$value
        rm (t)

      } else if (is.na(essmiles1) == FALSE) { #If essmiles exists but is NOT already in hash  table...

        #Perform search if info isn't already in hash table, then add info to output dataframe
        t <- htdesc (smile = qsardataframe$r1.es.smiles[i], HT.type = "es", sigma.selection, ...)

        hash_es[[essmiles1]] <- t #Add to hash table

        qsardataframe$r1.es.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.es.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.es.value[i] <- t$value
        rm (t)
      }


    } else { #If structure DOES have substitutions on aromatic ring... then taft, ind, and es values will always be for a phenyl ring

      # if the structure is aromatic, than we will set these to default values

      qsardataframe$r1.taft.smiles[i] <- "*C1=CC=CC=C1"
      qsardataframe$r1.es.smiles[i] <- "*C1=CC=CC=C1"
      qsardataframe$r1.ind.smiles[i] <- "*C1=CC=CC=C1"

      # calling htdesc helper function to fill substitute mcs values
      t <- helper (type = "taft", sigma.select = sigma.selection)
      qsardataframe$r1.taft.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r1.taft.mcs.index[i] <- t$tanimoto
      qsardataframe$r1.taft.value[i] <- t$value
      rm (t)

      t <- helper (type = "inductive", sigma.select = sigma.selection)
      qsardataframe$r1.ind.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r1.ind.mcs.index[i] <- t$tanimoto
      qsardataframe$r1.ind.value[i] <- t$value
      rm (t)

      t <- helper (type = "es", sigma.select = sigma.selection)
      qsardataframe$r1.es.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r1.es.mcs.index[i] <- t$tanimoto
      qsardataframe$r1.es.value[i] <- t$value
      rm (t)

    }

    if (is.na(qsardataframe$r1.meta1.smiles[i]) == FALSE) { #If structure has meta substitution in first position...

      if (hash::has.key(meta1smiles1, hash_meta) == TRUE) { #If smiles is in hash table already, use that info...

        t <- hash_meta[[meta1smiles1]]
        qsardataframe$r1.meta1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.meta1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.meta1.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table.

        t <- htdesc (smile = qsardataframe$r1.meta1.smiles[i], HT.type = "meta", sigma.selection, ...)

        hash_meta[[meta1smiles1]] <- t #Add to hash table

        qsardataframe$r1.meta1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.meta1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.meta1.value[i] <- t$value
        rm (t)
      }
    }

    if (is.na(qsardataframe$r1.meta2.smiles[i]) == FALSE) { #If structure has meta substitution in second position...

      if (hash::has.key(meta1smiles2, hash_meta) == TRUE) { #If smiles is already in hash table, use that info...

        t <- hash_meta[[meta1smiles2]]
        qsardataframe$r1.meta2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.meta2.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.meta2.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r1.meta2.smiles[i], HT.type = "meta", sigma.selection, ...)

        hash_meta[[meta1smiles2]] <- t #Add to hash table

        qsardataframe$r1.meta2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.meta2.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.meta2.value[i] <- t$value
        rm (t)
      }
    }

    if (is.na(qsardataframe$r1.ortho1.smiles[i]) == FALSE) { #If structure has ortho substitution in first position...

      if (hash::has.key(ortho1smiles1, hash_ortho) == TRUE) { #If smiles is already in hash table, use that info...

        t <- hash_ortho[[ortho1smiles1]]
        qsardataframe$r1.ortho1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ortho1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ortho1.value[i] <- t$value
        rm(t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r1.ortho1.smiles[i], HT.type = "ortho", sigma.selection, ...)

        hash_ortho[[ortho1smiles1]] <- t #Add to hash table

        qsardataframe$r1.ortho1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ortho1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ortho1.value[i] <- t$value
        rm (t)
      }
    }

    if (is.na(qsardataframe$r1.ortho2.smiles[i]) == FALSE) { #If structure has ortho substitution in second position...

      if (hash::has.key(ortho1smiles2, hash_ortho) == TRUE) { #If smiles is already in hash table, use that info...

        t <- hash_ortho[[ortho1smiles2]]
        qsardataframe$r1.ortho2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ortho2.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ortho2.value[i] <- t$value
        rm(t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r1.ortho2.smiles[i], HT.type = "ortho", sigma.selection, ...)

        hash_ortho[[ortho1smiles2]] <- t #Add to hash table

        qsardataframe$r1.ortho2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.ortho2.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.ortho2.value[i] <- t$value
        rm (t)
      }
    }

    if (is.na(qsardataframe$r1.para1.smiles[i]) == FALSE) { #If structure has para substitution...

      if (hash::has.key(parasmiles1, hash_para) == TRUE) { #If smiles is already in hash table, use that info...

        t <- hash_para[[parasmiles1]]
        qsardataframe$r1.para1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.para1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.para1.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r1.para1.smiles[i], HT.type = "para", sigma.selection, ...)

        hash_para[[parasmiles1]] <- t #Add to hash table

        qsardataframe$r1.para1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r1.para1.mcs.index[i] <- t$tanimoto
        qsardataframe$r1.para1.value[i] <- t$value
        rm (t)
      }
    }

    #For R2

    if (is.na(qsardataframe$r2.meta1.smiles[i]) & is.na(qsardataframe$r2.ortho1.smiles[i]) & is.na(qsardataframe$r2.para1.smiles[i]) == TRUE) { #If structure does not have substitutions on aromatic ring on R2...

      if (is.na(taftsmiles2) == FALSE && hash::has.key(taftsmiles2, hash_taft) == TRUE) { #If taftsmiles exists and the key is already in the hash table, use that info

        t <- hash_taft[[taftsmiles2]]
        qsardataframe$r2.taft.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.taft.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.taft.value[i] <- t$value
        rm (t)

      } else if (is.na(taftsmiles2) == FALSE) { #If taftsmiles exists and the key is NOT in the hash table, call htdesc and add to hash table

        # calling htdesc to fill substitute mcs values

        t <- htdesc (smile = qsardataframe$r2.taft.smiles[i], HT.type = "taft", sigma.selection, ...)

        hash_taft[[taftsmiles2]] <- t #Add to hash table

        qsardataframe$r2.taft.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.taft.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.taft.value[i] <- t$value
        rm(t)
      }

      if (is.na(indsmiles2) == FALSE && hash::has.key(indsmiles2, hash_ind) == TRUE) { #If indsmiles exists and the key is already in the hash table, use that info

        t <- hash_ind[[indsmiles2]]
        qsardataframe$r2.ind.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ind.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ind.value[i] <- t$value
        rm (t)

      } else if (is.na(indsmiles2) == FALSE) { #If indsmiles exists and the key is NOT in the hash table, call htdesc and add to hash table


        t <- htdesc (smile = qsardataframe$r2.ind.smiles[i], HT.type = "inductive", sigma.selection, ...)

        hash_ind[[indsmiles2]] <- t #Add to hash table

        qsardataframe$r2.ind.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ind.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ind.value[i] <- t$value
        rm (t)

      }

      if (is.na(essmiles2) == FALSE && hash::has.key(essmiles2, hash_es) == TRUE) { #If essmiles exists and the key is already in the hash table, use that info

        t <- hash_es[[essmiles2]]
        qsardataframe$r2.es.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.es.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.es.value[i] <- t$value
        rm (t)

      } else if (is.na(essmiles2) == FALSE) { #If essmiles exists and the key is NOT in the hash table, call htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.es.smiles[i], HT.type = "es", sigma.selection, ...)

        hash_es[[essmiles2]] <- t #Add to hash table

        qsardataframe$r2.es.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.es.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.es.value[i] <- t$value
        rm (t)

      }


    } else { #If structure DOES have substitutions on aromatic ring... then taft, ind, and es values will always be for a phenyl ring

      # if the structure is aromatic, than we will set these to default values

      qsardataframe$r2.taft.smiles[i] <- "*C1=CC=CC=C1"
      qsardataframe$r2.es.smiles[i] <- "*C1=CC=CC=C1"
      qsardataframe$r2.ind.smiles[i] <- "*C1=CC=CC=C1"

      t <- helper (type = "taft", sigma.select = sigma.selection)
      qsardataframe$r2.taft.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r2.taft.mcs.index[i] <- t$tanimoto
      qsardataframe$r2.taft.value[i] <- t$value
      rm (t)

      t <- helper (type = "inductive", sigma.select = sigma.selection)
      qsardataframe$r2.ind.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r2.ind.mcs.index[i] <- t$tanimoto
      qsardataframe$r2.ind.value[i] <- t$value
      rm (t)

      t <- helper (type = "es", sigma.select = sigma.selection)
      qsardataframe$r2.es.sub.smiles[i] <- as.character (t$sub.smiles)
      qsardataframe$r2.es.mcs.index[i] <- t$tanimoto
      qsardataframe$r2.es.value[i] <- t$value
      rm (t)

    }

    if (is.na(qsardataframe$r2.meta1.smiles[i]) == FALSE) { #If structure has a meta substitution in the first position...

      if (hash::has.key(meta2smiles1, hash_meta) == TRUE) { #If the meta key is in the hash table already, use that info...

        t <- hash_meta[[meta2smiles1]]
        qsardataframe$r2.meta1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.meta1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.meta1.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.meta1.smiles[i], HT.type = "meta", sigma.selection, ...)

        hash_meta[[meta2smiles1]] <- t #Add to hash table

        qsardataframe$r2.meta1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.meta1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.meta1.value[i] <- t$value
        rm (t)

      }
    }

    if (is.na(qsardataframe$r2.meta2.smiles[i]) == FALSE) { #If structure has meta substitution in second position...

      if (hash::has.key(meta2smiles2, hash_meta) == TRUE) { #If meta key is in the hash table, use that info

        t <- hash_meta[[meta2smiles2]]
        qsardataframe$r2.meta2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.meta2.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.meta2.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.meta2.smiles[i], HT.type = "meta", sigma.selection, ...)

        hash_meta[[meta2smiles2]] <- t #Add to hash table

        qsardataframe$r2.meta2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.meta2.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.meta2.value[i] <- t$value
        rm (t)

      }

    }

    if (is.na(qsardataframe$r2.ortho1.smiles[i]) == FALSE) { #If structure has ortho substitution in first position...

      if (hash::has.key(ortho2smiles1, hash_ortho) == TRUE) { #If ortho key exists in hash table, use that info

        t <- hash_ortho[[ortho2smiles1]]
        qsardataframe$r2.ortho1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ortho1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ortho1.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.ortho1.smiles[i], HT.type = "ortho", sigma.selection, ...)

        hash_ortho[[ortho2smiles1]] <- t #Add to hash table

        qsardataframe$r2.ortho1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ortho1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ortho1.value[i] <- t$value
        rm (t)

      }

    }

    if (is.na(qsardataframe$r2.ortho2.smiles[i]) == FALSE) { #If structure has ortho substitution in second position...

      if (hash::has.key(ortho2smiles2, hash_ortho) == TRUE) { #If ortho key is in hash table, use that info

        t <- hash_ortho[[ortho2smiles2]]
        qsardataframe$r2.ortho2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ortho2.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ortho2.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.ortho2.smiles[i], HT.type = "ortho", sigma.selection, ...)

        hash_ortho[[ortho2smiles2]] <- t #Add to hash table

        qsardataframe$r2.ortho2.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.ortho2.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.ortho2.value[i] <- t$value
        rm (t)

      }

    }

    if (is.na(qsardataframe$r2.para1.smiles[i]) == FALSE) { #If structure has para substitution...

      if (hash::has.key(parasmiles2, hash_para) == TRUE) { #If para key is already in hash table, use that info

        t <- hash_para[[parasmiles2]]
        qsardataframe$r2.para1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.para1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.para1.value[i] <- t$value
        rm (t)

      } else { #If not in hash table, run htdesc and add to hash table

        t <- htdesc (smile = qsardataframe$r2.para1.smiles[i], HT.type = "para", sigma.selection, ...)

        hash_para[[parasmiles2]] <- t #Add to hash table

        qsardataframe$r2.para1.sub.smiles[i] <- as.character (t$sub)
        qsardataframe$r2.para1.mcs.index[i] <- t$tanimoto
        qsardataframe$r2.para1.value[i] <- t$value
        rm (t)

      }

    }
  }

  #Replace NAs with 0 for .values cells
  valcols <- colnames(qsardataframe[grep("value$", colnames(qsardataframe))])
  qsardataframe[valcols][is.na(qsardataframe[c(valcols)])] <- 0


  closeAllConnections()
  # I am not sure why this is here, but dont remove it!!
  return(qsardataframe)

  #work still left
  # Low priority
  # insert output file format as a function attribute

  # high priority

  # insert a summation method which adds up values for hammetts

}
