###!
--- syncver ---

Released under MIT license.

by Gustavo Vargas - @xgvargas - 2018

Original coffee code and issues at: https://github.com/xgvargas/syncver
###

yargs = require 'yargs'
fs = require 'fs'
chalk = require 'chalk'
Table = require 'easy-table'


argv = yargs
# .wrap yargs.terminalWidth()
.strict yes
.alias 'h', 'help'
# .config 'cfg'
.usage 'Usage: $0 [options] [command]'
.epilogue 'copyright 2018'
# .demandCommand 1
# .commandDir 'cmds'
.options
    # cfg: {describe:'Configuration file', default:'./.syncverrc.json'}
    S: {alias:'save', describe:'Modify package.json', type:'boolean'}
    c: {alias:'caret', describe:'Use ^', type:'boolean', default: yes}
    t: {alias:'tilde', describe:'Use ~', type:'boolean'}
    n: {alias:'none', describe:'Use nothing', type:'boolean'}
.argv

#----------------


execute = (modules, mode) ->

    t = new Table

    res = {}
    for m, curVer of modules
        t.cell 'module', m
        try
            mpack = fs.readFileSync "./node_modules/#{m}/package.json"
            foundVer = mode + JSON.parse(mpack).version
            res[m] = foundVer

            t.cell 'declared', curVer
            if curVer == foundVer
                t.cell 'installed', foundVer
            else
                t.cell 'installed', chalk.green foundVer
            t.newRow()

        catch
            res[m] = curVer
            t.cell 'declared', curVer
            t.cell 'installed', chalk.red 'not installed'
            t.newRow()

    console.log t.toString()

    return res


try
    pack = JSON.parse fs.readFileSync './package.json'
catch
    console.log chalk.red('\nOops!'), "There is no #{chalk.blue('package.json')} in here...\n"
    process.exit 1

# TODO check if node_modules is here too!

mode = '^'
mode = '~' if argv.tilde
mode = '' if argv.none

console.log chalk.yellow "\nDependencies:"
pack.dependencies = execute pack.dependencies, mode
console.log chalk.yellow "Dev Dependencies:"
pack.devDependencies = execute pack.devDependencies, mode

# console.log ''

if argv.save
    console.log 'vou salddvar...'
    console.log JSON.stringify pack, null, 2
    a=1
