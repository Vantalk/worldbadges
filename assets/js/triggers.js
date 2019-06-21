import PostingTrigger    from './posting-triggers'

class Triggers {

  constructor (main) {
    let posting_trigger    = new PostingTrigger
    posting_trigger.initialize(main)
  }
}
export default Triggers
