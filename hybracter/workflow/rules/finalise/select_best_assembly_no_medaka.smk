"""
aggregate the ALE scores and pick the best one
"""

# to import aggregate_ale_input


# input function for the rule aggregate polca
def aggregate_ale_input_finalise(wildcards):
    # decision based on content of output file
    # Important: use the method open() of the returned file!
    # This way, Snakemake is able to automatically download the file if it is generated in
    # a cloud environment without a shared filesystem.
    with checkpoints.check_completeness.get(sample=wildcards.sample).output[
        0
    ].open() as f:
        if f.read().strip() == "C":  # complete
            if config.args.no_pypolca is False:  # with pypolca
                return os.path.join(
                    dir.out.ale_scores_complete, "{sample}", "pypolca.score"
                )
            else:  # with polca, best is polypolish
                return os.path.join(
                    dir.out.ale_scores_complete, "{sample}", "polypolish.score"
                )
        else:  # incomplete
            if config.args.no_pypolca is False:  # with pypolca
                return os.path.join(
                    dir.out.ale_scores_incomplete,
                    "{sample}",
                    "pypolca_incomplete.score",
                )
            else:
                return os.path.join(
                    dir.out.ale_scores_incomplete,
                    "{sample}",
                    "polypolish_incomplete.score",
                )


### from the aggregate_ale_input function - so it dynamic
# also calculates the summary
rule select_best_chromosome_assembly_complete:
    input:
        ale_input=aggregate_ale_input_finalise,
        aggr_ale_flag=os.path.join(dir.out.aggr_ale, "{sample}.txt"),  # to make sure ale has finished
        plassembler_fasta=os.path.join(
            dir.out.plassembler, "{sample}", "plassembler_plasmids.fasta"
        ),
        flye_info=os.path.join(
            dir.out.assembly_statistics, "{sample}_assembly_info.txt"
        ),
    output:
        chromosome_fasta=os.path.join(
            dir.out.final_contigs_complete, "{sample}_chromosome.fasta"
        ),
        plasmid_fasta=os.path.join(
            dir.out.final_contigs_complete, "{sample}_plasmid.fasta"
        ),
        total_fasta=os.path.join(dir.out.final_contigs_complete, "{sample}_final.fasta"),
        ale_summary=os.path.join(dir.out.ale_summary, "complete", "{sample}.tsv"),
        hybracter_summary=os.path.join(
            dir.out.final_summaries_complete, "{sample}_summary.tsv"
        ),
        per_conting_summary=os.path.join(
            dir.out.final_summaries_complete, "{sample}_per_contig_stats.tsv"
        ),
    params:
        ale_dir=os.path.join(dir.out.ale_scores_complete, "{sample}"),
        chrom_pre_polish_fasta=os.path.join(
            dir.out.dnaapler, "{sample}", "{sample}_reoriented.fasta"
        ),
        polypolish_fasta=os.path.join(dir.out.polypolish, "{sample}.fasta"),
        polca_fasta=os.path.join(
            dir.out.pypolca, "{sample}", "{sample}_corrected.fasta"
        ),
    resources:
        mem_mb=config.resources.sml.mem,
        mem=str(config.resources.sml.mem) + "MB",
        time=config.resources.sml.time,
    conda:
        os.path.join(dir.env, "scripts.yaml")
    threads: config.resources.sml.cpu
    script:
        os.path.join(
            dir.scripts_no_medaka, "select_best_chromosome_assembly_complete.py"
        )


### from the aggregate_ale_input function - so it dynamic
#  also calculates the summary
rule select_best_chromosome_assembly_incomplete:
    input:
        ale_input=aggregate_ale_input,
        ale_flag=os.path.join(dir.out.aggr_ale, "{sample}.txt"),  # to make sure ale has finished
        flye_info=os.path.join(
            dir.out.assembly_statistics, "{sample}_assembly_info.txt"
        ),
    output:
        fasta=os.path.join(dir.out.final_contigs_incomplete, "{sample}_final.fasta"),
        ale_summary=os.path.join(dir.out.ale_summary, "incomplete", "{sample}.tsv"),
        hybracter_summary=os.path.join(
            dir.out.final_summaries_incomplete, "{sample}_summary.tsv"
        ),
        per_conting_summary=os.path.join(
            dir.out.final_summaries_incomplete, "{sample}_per_contig_stats.tsv"
        ),
    params:
        ale_dir=os.path.join(dir.out.ale_scores_incomplete, "{sample}"),
        pre_polish_fasta=os.path.join(dir.out.incomp_pre_polish, "{sample}.fasta"),
        polypolish_fasta=os.path.join(dir.out.polypolish_incomplete, "{sample}.fasta"),
        polca_fasta=os.path.join(
            dir.out.pypolca_incomplete, "{sample}", "{sample}_corrected.fasta"
        ),
    resources:
        mem_mb=config.resources.sml.mem,
        mem=str(config.resources.sml.mem) + "MB",
        time=config.resources.sml.time,
    conda:
        os.path.join(dir.env, "scripts.yaml")
    threads: config.resources.sml.cpu
    script:
        os.path.join(
            dir.scripts_no_medaka, "select_best_chromosome_assembly_incomplete.py"
        )