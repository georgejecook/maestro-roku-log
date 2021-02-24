/**
 * Installs a local version of all the rokucommunity dependent packages into this project
 */

import * as fsExtra from 'fs-extra';
import * as path from 'path';
import * as childProcess from 'child_process';
import * as rimraf from 'rimraf';

//set the cwd to the root of this project
let thisProjectRootPath = path.join(__dirname, '..');
process.chdir(thisProjectRootPath);
let packageJson = JSON.parse(fsExtra.readFileSync('package.json').toString());

let packages = {
};

for (let packageName in packages) {
    console.log(`adding '${packageName}' to package.json`);
    packageJson.dependencies[packageName] = `${packages[packageName]}`;
    rimraf.sync(path.join('node_modules', packageName));
}

let devPackages = [
  'brighterscript',
  'roku-log-bsc-plugin',
  'maestro-roku-bsc-plugin',
  'rooibos-roku',
];

for (let packageName of devPackages) {
  console.log(`removing package: '${packageName}' from package.json`);
  delete(packageJson.devDependencies[packageName]);
  rimraf.sync(path.join('node_modules', packageName));
}

console.log('saving package.json changes');
fsExtra.writeFileSync('package.json', JSON.stringify(packageJson, null, 4));
if (fsExtra.existsSync('package-lock.json')) {
  fsExtra.rmSync('package-lock.json');
}

console.log('install packages');
for (let packageName of devPackages) {
  console.log(`adding dev package: '${packageName}' to package.json`);
  childProcess.execSync(`npm i ${packageName} --save-dev`, {
    stdio: 'inherit'
  });
}
