#!/usr/bin/env zx

$.verbose = false;

const recentBranchesString = await $`git reflog`
	.pipe($`egrep -io 'moving from ([^[:space:]]+)'`)
	.pipe($`awk '{ print $3 }'`)
	.pipe($`awk ' !x[$0]++'`);

const recentBranches = recentBranchesString.stdout.split("\n").splice(0, 10);

if (argv.c || argv.checkout) {
	$.verbose = true;
	await $`git checkout ${recentBranches[(argv.c || argv.checkout) - 1]}`;
} else {
	recentBranches.forEach((line, i) => console.log(`${i + 1} ${line}`));
}
