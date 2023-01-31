
// enable dsl syntax extension (should be applied by default)
nextflow.enable.dsl = 2

// DEFINING & PRINTING VARIABLES
start_message = """
 ------------------------ 
      NEXTFLOW TESTING    
  WORKFLOW START MESSAGE  
 ------------------------ 
"""
println(start_message)



/* WORKFLOW INTROSPECTION */
println("\nWORKFLOW:")
println("run command:  \"${workflow.commandLine}\"")
println("run info:     ${workflow.runName} (id ${workflow.sessionId})")
println("launch dir:   ${workflow.launchDir}") // working directory (pwd)

println("scipt info:   ${workflow.scriptName} (revision ${workflow.revision})")
println("project dir:  ${workflow.projectDir}") // projectDIR/workflow.nf
println("config files: ${workflow.configFiles}")
println("work dir:     ${workflow.workDir}") // launchDIR/work (-w)

/* PROFILE SETTINGS

nextflow.config (-c) format:

profiles {
    profile_name {
        directive = value
    }
} 

*/


println("\nPROFILE:")

println("config profile:   ${workflow.profile}")
println("container engine: ${workflow.containerEngine}")


/* PARAMETER DEFAULTS


i) command line override:

run nextflow /path/to/worflow.nf --flagN argument


ii) workflow.nf format:

params.flagN = argument


iii) nextflow.config (-c) / params-file (-p) format:

params {
    flag1 = "argument"
    flag2 = 1
    flag3 = true
    flag4 = null
} */

params.null1 = null

println("\nPARAMETERS:")
println("input:  ${params.input}")
println("output: ${params.output}")
println("value1: ${params.value1}")
println("value2: ${params.value2}")
println("bool1:  ${params.bool1}")
println("bool2:  ${params.bool2}")
println("null1:  ${params.null1}")



/* PROCESSES DEFINITIONS */


/* define first process */

process PROCESS1 {


/* DIRECTIVES (OPTIONAL) */

    /* Submitted process > PROCESS_NAME (TAG) */
    tag "${INPUT_TXT1}${INPUT_TXT2}"

    /* print stdout */
    debug true


/* DECLARATIONS (REQUIRED) */

    /* define process inputs & outputs */

    input:

    val INPUT_TAG
    val INPUT_VAL1
    val INPUT_VAL2
    
    output:

    tuple file("${INPUT_TAG}_${INPUT_VAL1}.csv"), val(INPUT_VAL2), emit: PROCESS1_INFO
    stdout                                                         emit: PROCESS1_STD


    /* define [ script | shell | exec ] */

    /*
    script:         $var  (nextflow)   \$var (bash)
        template    $var  (nextflow)    $var (bash)    
    shell:         !{var} (nextflow)    $var (bash)
    exec:           $var  (nextflow)
    */

    //template ['template.sh'|'/path/to/template.sh']
    /* N.B. template.sh should be located in templates/ subdir */

    script:

    """
    TABLE_NAME="${INPUT_TAG}_${INPUT_VAL1}.csv"

    > \$TABLE_NAME

    for row in {0..10}; do

        line=""

        for column in {0..10}; do

        # 1st column (variable unset)
        if [ -z \$line ]; then

        line="${INPUT_VAL1}"

        # nth column (variable set)
        else

        line="\$line,${INPUT_VAL1}"

        fi

        done

    echo \$line >> "\$TABLE_NAME"

    done

    cat \$TABLE_NAME
    """
    
    /* define test [ script | shell | exec ] (-stub-run / -stub) */

    //stub:

    } 



process PROCESS2 {

    tag "table ${INPUT_VAL2}"

    /* define script executed [before|after] process */
    /* N.B. executed outside container & prior to 'module' */
    //beforeScript ''
    //afterScript ''
    
    /* contains demo_script.py */
    //container "mattheatley/demo_image:v1"

    /* relies on bin/demo_script.py */
    container "mattheatley/demo_image:nf-xplat"

    /* output directories */
    publishDir path:      "./pub/${workflow.sessionId}/${task.process}", 
               mode:      'copy', 
               overwrite: true, 
               pattern:   "TABLE_[A-Z].csv",
               saveAs:    { fileinfo -> file(fileinfo).getName() }

    debug true

    input:

    tuple file(INPUT_FILE), val(INPUT_VAL2)

    output:

    path("TABLE_[A-Z].csv"), emit: PROCESS2_FILE
    stdout                   emit: PROCESS2_STD


    script:
    // here i modify a table
    /* currently:  demo_script.py (executable) */
    /* previously: python /demo_script.py */
    """
    echo
    echo "PATH:\$PATH"
    DemoScript.py -i ${INPUT_FILE} -o TABLE_${INPUT_VAL2}.csv -v ${INPUT_VAL2}
    pwd
    ls -1
    """

}







/* WORKFLOW LAYOUT */

workflow{
    
    CHANNEL_TAG = Channel.value('TABLE')

    CHANNEL_VAL1 = Channel.of(
        1,
        2,
        3, )

    CHANNEL_VAL2 = Channel.of(
        'A',
        'B',
        'C', )



/* PROCESS 1 */

    println "running 1st process..."

    /* run process */
    PROCESS1(
        CHANNEL_TAG,
        CHANNEL_VAL1,
        CHANNEL_VAL2,)

    /* extract process outputs */
    CHANNEL_PROCESS1_INFO = PROCESS1.out.PROCESS1_INFO
    CHANNEL_PROCESS1_STD  = PROCESS1.out.PROCESS1_STD

    /* view process outputs */
    CHANNEL_PROCESS1_INFO.view( { file, tag -> "created: ${file}" } )





/* PROCESS 2 */

    println "running 2nd process..."

    /* run process */
    PROCESS2(
        CHANNEL_PROCESS1_INFO, )

    /* extract process outputs */
    CHANNEL_PROCESS2_FILE = PROCESS2.out.PROCESS2_FILE
    CHANNEL_PROCESS2_STD  = PROCESS2.out.PROCESS2_STD

    /* view process outputs */
    CHANNEL_PROCESS2_FILE.view( { file -> "updated: ${file}" } )

}
