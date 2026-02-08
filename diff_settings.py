def apply(config, args):
    basename = "SLPM_861.83"

    config["arch"] = "mipsel"
    config['baseimg'] = f'iso/SLPM_861.83'
    config['myimg'] = f'build/out/SLPM_861.83'
    config['mapfile'] = f'build/out/SLPM_861.83.map'
    config['source_directories'] = [f'src/SLPM_861.83', 'include', f'asm/SLPM_861.83']
    config["make_command"] = ["make", "clean-build"]
