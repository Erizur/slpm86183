def apply(config, args):
    config["arch"] = "mipsel"
    config['baseimg'] = f'iso/SLPM_861.83'
    config['myimg'] = f'build/SLPM_861.83'
    config['mapfile'] = f'build/pnmcs.map'
    config['source_directories'] = [f'src/game', 'include', f'asm/game']
