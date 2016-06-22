#!/bin/bash
#
# Display/Delete old merged or orphaned git branches.
#
# Usage: 
#	1. Clone the repo and fetch the latest commits
# 	2. Run the script with dry-run, or interactive flag options using the command below:
#	3. Without any options, the branches to be deleted are just shown
#	4. Use git-cleanup-branch.sh --help to show the usage
#		
# Details: 
# Get the branch details from git and list the merged and orphaned branches
# Depending on the flags, iterate and display/delete the branches
# Creates a couple of temp files, that will be cleaned up

git checkout master

# List of branches merged into master, except develop and release* branches
for branch in `git branch -a --merged master | grep -v -e release -e master -e develop`;
	do echo -e `git show --format="%ci %cr" $branch | head -n 1` \\t$branch; 
done | sort -r | cut -d/ -f2- > $MERGED_BRANCHES

# Branches not merged, and where the oldest commit was > 3 months ago
for branch in `git branch -a --no-merged master | grep -v -e release -e master -e develop`; 
	do echo -e `git show --format="%ci %cr" $branch | head -n 1` \\t$branch; 
done | sort -r | grep months | grep -v "[0:2] months ago" | cut -d/ -f2- > $ORPHANED_BRANCHES

# Iterate merged branches
while read branch; do     
	printf  "Merged branch: %s" $branch;     
	printf "\tLast commit was: %s\n" "$(git show --format="%cr" $branch | head -n 1)"; 
done < $MERGED_BRANCHES;

# Iterate orphaned branches
while read branch; do     
	printf  "Orphaned branch: %s" $branch;     
	printf "\tLast commit was: %s\n" "$(git show --format="%cr" $branch | head -n 1)"; 
done < $ORPHANED_BRANCHES;

# cleanup
rm $MERGED_BRANCHES
rm $ORPHANED_BRANCHES
