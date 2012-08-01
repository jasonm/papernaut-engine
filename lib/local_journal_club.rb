# thin wrapper around job, for use by Loader and execution inside the JCAPI process
class LocalJournalClub
  def create_discussion(url)
    DiscussionLinkJob.work(url)
  end
end
