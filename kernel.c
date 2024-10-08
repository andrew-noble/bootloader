void main() {
    char* video_memory = (char*) 0xb8000; //the memory-mapped location of VGA display text
    *video_memory = 'X'; //what to store at that VGA location
}