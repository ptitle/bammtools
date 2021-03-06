
# phy is a phylogenetic tree
# traits is a file name to your BAMM formatted data.
# total.taxa is only if you have incomplete sampling
# 
# 

setBAMMpriors <- function(phy, total.taxa = NULL, traits=NULL, outfile = 'myPriors.txt', Nmax = 1000){
	
	if (is.ultrametric(phy)) {
		mbt <- max(branching.times(phy));
	} else {
		mbt <- max(NU.branching.times(phy));
	}
	if (is.null(total.taxa)){
		total.taxa <- length(phy$tip.label);
	}
	if (is.null(traits)){
		
		pb <- (log(total.taxa) - log(2)) / mbt;
		lamprior <- 1/(pb * 5);
		lamrootprior <- 1/(pb * 1);
		k1 <- log(0.1) / mbt;
		kprior <- -1*(k1/2);	
		
		s1 <- '###############################################';
		s2 <- '# Prior block chosen by BAMMtools::setBAMMpriors';
		s3 <- 'poissonRatePrior = 1.0';
		s4 <- paste('lambdaInitPrior = ', lamprior, sep='');
		s5 <- paste('lambdaShiftPrior = ', kprior, sep='');
		s6 <- paste('muInitPrior = ', lamprior, sep='');
		s7 <- paste('#### End Prior block\n######################\n\n');
		ss <- paste(s1,s2,s3,s4,s5,s6,s7, sep='\n\n');
		if (!is.null(outfile)) {
			write(ss, file = outfile, sep='');
		} else {
			res <- as.data.frame(cbind(c('poissonRatePrior', 'lambdaInitPrior', 'lambdaShiftPrior', 'muInitPrior'), c(1.0, lamprior, kprior, lamprior)), stringsAsFactors=FALSE);
			res[,2] <- as.numeric(res[,2]);
			colnames(res) <- c('param','value');
		}
	}else{
		x <- read.table(file = traits, sep='\t', stringsAsFactors=F, header=F);
		tvec <- x[,2];
		names(tvec) <- x[,1];
		not.in.tree <- setdiff(phy$tip.label, names(tvec));
		not.in.traits <- setdiff(names(tvec), phy$tip.label);
		bad <- c(not.in.tree, not.in.traits);
		if (length(bad) > 0){
			cat('Taxon names do not match between tree and trait dataset\n');
			cat('Printing mismatched names:\n\n');
			for (i in bad){
				cat(i, '\n');
			}
			stop('Names in trait dataset must match those in tree\n');
		}
		tvec <- tvec[phy$tip.label];
		if (length(phy$tip.label) > Nmax){
			ss <- sample(phy$tip.label, size=Nmax);
			drop <- setdiff(phy$tip.label, ss);
			phy <- drop.tip(phy, tip = drop);
			tvec <- tvec[phy$tip.label];
		}
		pmean <- phylogeneticMean(tvec, phy)$beta;
		
		betaprior <- 1/(pmean * 5);
		betarootprior <- 1/(pmean * 1);		
		
		k1 <- log(0.1) / mbt;
		kprior <- -1*(k1/2);	
		
		s1 <- '###############################################';
		s2 <- '# Prior block chosen by BAMMtools::setBAMMpriors';
		s3 <- 'poissonRatePrior = 1.0';
		s4 <- paste('betaInitPrior = ', betaprior, sep='');
		s5 <- paste('betaShiftPrior = ', kprior, sep='');
		s6 <- paste('useObservedMinMaxAsTraitPriors = 1');
		s7 <- paste('#### End Prior block\n######################\n\n');
		ss <- paste(s1,s2,s3,s4,s5,s6,s7,sep='\n\n');
		if (!is.null(outfile)) {
			write(ss, file = outfile, sep='');
		} else {
			res <- as.data.frame(cbind(c('poissonRatePrior', 'betaInitPrior', 'betaShiftPrior', 'useObservedMinMaxAsTraitPriors'), c(1.0, betaprior, kprior, 1)), stringsAsFactors=FALSE);
			res[,2] <- as.numeric(res[,2]);
			colnames(res) <- c('param','value');
		}
				
	}

	if (!is.null(outfile)) {	
		cat('\nPrior block written to file << ', outfile, " >>\n", sep='');
		cat('Copy and paste the contents of the file into the\n');
		cat('priors block of your BAMM input file\n');
	}

	cat('\nThis function simply sets the poissonRatePrior to 1;\n');
	cat('This is a parameter you may need to vary to achieve good convergence\n');
	cat('with your data.\n');

	if (is.null(outfile)) {
		return(res);
	}	
}







